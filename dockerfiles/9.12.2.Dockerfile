ARG GHC_VERSION=9.12.2
ARG CABAL_VERSION=3.14.2.0
ARG STACK_VERSION=3.5.1
ARG LLVM_VERSION=20

ARG GHC_VERSION_BUILD=${GHC_VERSION}
ARG CABAL_VERSION_BUILD=${CABAL_VERSION}

FROM glcr.b-data.ch/ghc/ghc-musl:9.10.2 AS bootstrap

RUN case "$(uname -m)" in \
    x86_64) linker="gold" ;; \
    aarch64) linker="gold" ;; \
  esac \
  && apk upgrade --no-cache \
  && apk add --no-cache \
    autoconf \
    automake \
    binutils${linker:+-}${linker} \
    build-base \
    clang20 \
    coreutils \
    cpio \
    curl \
    gnupg \
    linux-headers \
    libffi-dev \
    lld20 \
    llvm20 \
    ncurses-dev \
    perl \
    python3 \
    xz \
    zlib-dev

FROM bootstrap AS bootstrap-ghc

ARG GHC_VERSION_BUILD
ARG GHC_NATIVE_BIGNUM

ENV GHC_VERSION=${GHC_VERSION_BUILD}

COPY patches/${GHC_VERSION}.patch /tmp/

RUN cd /tmp \
  && curl -sSLO https://downloads.haskell.org/~ghc/"$GHC_VERSION"/ghc-"$GHC_VERSION"-src.tar.xz \
  && curl -sSLO https://downloads.haskell.org/~ghc/"$GHC_VERSION"/ghc-"$GHC_VERSION"-src.tar.xz.sig \
  && gpg --keyserver hkps://keyserver.ubuntu.com:443 \
    --receive-keys FFEB7CE81E16A36B3E2DED6F2DE04D4E97DB64AD || \
    gpg --keyserver hkp://keyserver.ubuntu.com:80 \
    --receive-keys FFEB7CE81E16A36B3E2DED6F2DE04D4E97DB64AD \
  && gpg --verify "ghc-$GHC_VERSION-src.tar.xz.sig" "ghc-$GHC_VERSION-src.tar.xz" \
  && tar -xJf "ghc-$GHC_VERSION-src.tar.xz" \
  && cd "ghc-$GHC_VERSION" \
  ## Apply patch: Bump max LLVM version to 21 (not inclusive)
  && mv "/tmp/$GHC_VERSION.patch" . \
  && patch -p0 <"$GHC_VERSION.patch" \
  ## Configure and build
  && if [ "$(uname -m)" = "riscv64" ]; then \
    flavour=quick+llvm${GHC_NATIVE_BIGNUM:++native_bignum}; \
  fi \
  && ./boot.source \
  && ./configure \
    --build=$(uname -m)-alpine-linux \
    --host=$(uname -m)-alpine-linux \
    --target=$(uname -m)-alpine-linux \
    --disable-ld-override LD=ld.lld \
  ## Use the LLVM backend
  ## Switch llvm-targets from unknown-linux-gnueabihf->alpine-linux
  ## so we can match the llvm vendor string alpine uses
  && sed -i -e 's/unknown-linux-gnueabihf/alpine-linux/g' llvm-targets \
  && sed -i -e 's/unknown-linux-gnueabi/alpine-linux/g' llvm-targets \
  && sed -i -e 's/unknown-linux-gnu/alpine-linux/g' llvm-targets \
  && cabal update \
  && cabal install alex \
  && export PATH=/root/.local/bin:$PATH \
  ## See https://unix.stackexchange.com/questions/519092/what-is-the-logic-of-using-nproc-1-in-make-command
  && hadrian/build binary-dist -j"$(($(nproc)+1))" \
    --flavour=${flavour:-perf+split_sections+llvm${GHC_NATIVE_BIGNUM:++native_bignum}} \
    --docs=none

FROM bootstrap AS bootstrap-cabal

ARG CABAL_VERSION_BUILD

ENV CABAL_VERSION=${CABAL_VERSION_BUILD}

## Build Cabal (the tool) with the GHC bootstrap version
RUN cabal update \
  ## See https://gitlab.haskell.org/ghc/ghc/-/wikis/commentary/libraries/version-history
  && cabal install "cabal-install-$CABAL_VERSION"

FROM alpine:3.22 AS ghc-base

ARG IMAGE_LICENSE="MIT"
ARG IMAGE_SOURCE="https://gitlab.b-data.ch/ghc/ghc-musl"
ARG IMAGE_VENDOR="Olivier Benz"
ARG IMAGE_AUTHORS="Olivier Benz <olivier.benz@b-data.ch>"

LABEL org.opencontainers.image.licenses="$IMAGE_LICENSE" \
      org.opencontainers.image.source="$IMAGE_SOURCE" \
      org.opencontainers.image.vendor="$IMAGE_VENDOR" \
      org.opencontainers.image.authors="$IMAGE_AUTHORS"

ARG GHC_VERSION_BUILD
ARG CABAL_VERSION_BUILD
ARG STACK_VERSION
ARG LLVM_VERSION

ENV GHC_VERSION=${GHC_VERSION_BUILD} \
    CABAL_VERSION=${CABAL_VERSION_BUILD} \
    STACK_VERSION=${STACK_VERSION} \
    LLVM_VERSION=${LLVM_VERSION}

RUN apk add --no-cache \
    bash \
    build-base \
    bzip2 \
    bzip2-dev \
    bzip2-static \
    clang${LLVM_VERSION} \
    curl \
    curl-static \
    dpkg \
    fakeroot \
    git \
    gmp-dev \
    gmp-static \
    libcurl \
    libffi \
    libffi-dev \
    lld${LLVM_VERSION} \
    llvm${LLVM_VERSION} \
    ncurses-dev \
    ncurses-static \
    openssl-dev \
    openssl-libs-static \
    pcre \
    pcre-dev \
    pcre2 \
    pcre2-dev \
    perl \
    ## Install shadow for `stack --docker`
    shadow \
    wget \
    xz \
    xz-dev \
    zlib \
    zlib-dev \
    zlib-static

FROM ghc-base AS ghc-stage1

ARG GHC_NATIVE_BIGNUM

COPY --from=bootstrap-ghc /tmp/ghc-"$GHC_VERSION"/_build/bindist/ghc-"$GHC_VERSION"-*-alpine-linux.tar.xz /tmp/

RUN cd /tmp \
  ## Install GHC
  && tar -xJf ghc-"$GHC_VERSION"-*-alpine-linux.tar.xz \
  && cd ghc-"$GHC_VERSION"-*-alpine-linux \
  && if [ -n "$GHC_NATIVE_BIGNUM" ]; then \
    ./configure; \
  else \
    ./configure --disable-ld-override; \
  fi \
  && make install \
  ## Install Stack
  && cd /tmp \
  && if [ "$(uname -m)" = "riscv64" ]; then \
    curl -sSLO https://gitlab.b-data.ch/commercialhaskell/stack/-/releases/v"$STACK_VERSION"/downloads/builds/stack-"$STACK_VERSION"-linux-"$(uname -m)".tar.gz; \
    curl -sSLO https://gitlab.b-data.ch/commercialhaskell/stack/-/releases/v"$STACK_VERSION"/downloads/builds/stack-"$STACK_VERSION"-linux-"$(uname -m)".tar.gz.sha256; \
  else \
    curl -sSLO https://github.com/commercialhaskell/stack/releases/download/v"$STACK_VERSION"/stack-"$STACK_VERSION"-linux-"$(uname -m)".tar.gz; \
    curl -sSLO https://github.com/commercialhaskell/stack/releases/download/v"$STACK_VERSION"/stack-"$STACK_VERSION"-linux-"$(uname -m)".tar.gz.sha256; \
  fi \
  && sha256sum -cs stack-"$STACK_VERSION"-linux-"$(uname -m)".tar.gz.sha256 \
  && tar -xzf stack-"$STACK_VERSION"-linux-"$(uname -m)".tar.gz \
  && mv stack-"$STACK_VERSION"-linux-"$(uname -m)"/stack /usr/local/bin/stack \
  ## Clean up
  && rm -rf /tmp/*

FROM ghc-stage1 AS ghc-stage2

## Install Cabal (the tool) built with the GHC bootstrap version
COPY --from=bootstrap-cabal /root/.local/bin/cabal /usr/local/bin/cabal

## Rebuild Cabal (the tool) with the GHC target version
RUN cabal update \
  && cabal install "cabal-install-$CABAL_VERSION"

FROM ghc-stage1 AS test

WORKDIR /usr/local/src

## Install Cabal (the tool) built with the GHC target version
COPY --from=ghc-stage2 /root/.local/bin/cabal /usr/local/bin/cabal

COPY Main.hs Main.hs

RUN ghc -static -optl-pthread -optl-static Main.hs \
  && file Main \
  && ./Main \
  ## Test cabal workflow
  && mkdir cabal-test \
  && cd cabal-test \
  && cabal update \
  && cabal init -n --is-executable -p tester -l MIT \
  && cabal run

FROM ghc-base

## Install GHC and Stack
COPY --from=ghc-stage1 /usr/local /usr/local

## Install Cabal (the tool) built with the GHC target version
COPY --from=ghc-stage2 /root/.local/bin/cabal /usr/local/bin/cabal

CMD ["ghci"]
