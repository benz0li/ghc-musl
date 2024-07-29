ARG GHC_VERSION=9.6.6
ARG CABAL_VERSION=3.10.3.0
ARG STACK_VERSION=3.1.1

ARG GHC_VERSION_BUILD=${GHC_VERSION}
ARG CABAL_VERSION_BUILD=${CABAL_VERSION}

FROM glcr.b-data.ch/ghc/ghc-musl:9.4.8 as bootstrap

RUN apk upgrade --no-cache \
  && apk add --no-cache \
    autoconf \
    automake \
    binutils-gold \
    build-base \
    coreutils \
    cpio \
    curl \
    gnupg \
    linux-headers \
    libffi-dev \
    llvm16 \
    ncurses-dev \
    perl \
    python3 \
    xz \
    zlib-dev

FROM bootstrap as bootstrap-ghc

ARG GHC_VERSION_BUILD

ENV GHC_VERSION=${GHC_VERSION_BUILD}

COPY patches/${GHC_VERSION}.patch /tmp/

RUN cd /tmp \
  && curl -sSLO https://downloads.haskell.org/~ghc/"$GHC_VERSION"/ghc-"$GHC_VERSION"-src.tar.xz \
  && curl -sSLO https://downloads.haskell.org/~ghc/"$GHC_VERSION"/ghc-"$GHC_VERSION"-src.tar.xz.sig \
  && gpg --keyserver hkps://keyserver.ubuntu.com:443 \
    --receive-keys 88B57FCF7DB53B4DB3BFA4B1588764FBE22D19C4 || \
    gpg --keyserver hkp://keyserver.ubuntu.com:80 \
    --receive-keys 88B57FCF7DB53B4DB3BFA4B1588764FBE22D19C4 \
  && gpg --verify "ghc-$GHC_VERSION-src.tar.xz.sig" "ghc-$GHC_VERSION-src.tar.xz" \
  && tar -xJf "ghc-$GHC_VERSION-src.tar.xz" \
  && cd "ghc-$GHC_VERSION" \
  ## Apply patch: Bump max LLVM version to 19 (not inclusive)
  ## https://gitlab.haskell.org/ghc/ghc/-/merge_requests/12726
  && mv "/tmp/$GHC_VERSION.patch" . \
  && patch -p0 <"$GHC_VERSION.patch" \
  ## Configure and build
  && ./boot.source \
  && ./configure --disable-ld-override LD=ld.gold \
  ## Use the LLVM backend
  ## Switch llvm-targets from unknown-linux-gnueabihf->alpine-linux
  ## so we can match the llvm vendor string alpine uses
  && sed -i -e 's/unknown-linux-gnueabihf/alpine-linux/g' llvm-targets \
  && sed -i -e 's/unknown-linux-gnueabi/alpine-linux/g' llvm-targets \
  && sed -i -e 's/unknown-linux-gnu/alpine-linux/g' llvm-targets \
  && cabal update \
  ## See https://unix.stackexchange.com/questions/519092/what-is-the-logic-of-using-nproc-1-in-make-command
  && hadrian/build binary-dist -j"$(($(nproc)+1))" \
    --flavour=perf+llvm+split_sections \
    --docs=none

FROM bootstrap as bootstrap-cabal

ARG CABAL_VERSION_BUILD

ENV CABAL_VERSION=${CABAL_VERSION_BUILD}

## Build Cabal (the tool) with the GHC bootstrap version
RUN cabal update \
  ## See https://gitlab.haskell.org/ghc/ghc/-/wikis/commentary/libraries/version-history
  && cabal install "cabal-install-$CABAL_VERSION"

FROM alpine:3.20 as ghc-base

LABEL org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://gitlab.b-data.ch/ghc/ghc-musl" \
      org.opencontainers.image.vendor="Olivier Benz" \
      org.opencontainers.image.authors="Olivier Benz <olivier.benz@b-data.ch>"

ARG GHC_VERSION_BUILD
ARG CABAL_VERSION_BUILD
ARG STACK_VERSION

ENV GHC_VERSION=${GHC_VERSION_BUILD} \
    CABAL_VERSION=${CABAL_VERSION_BUILD} \
    STACK_VERSION=${STACK_VERSION}

RUN apk add --no-cache \
    bash \
    build-base \
    bzip2 \
    bzip2-dev \
    bzip2-static \
    curl \
    curl-static \
    dpkg \
    fakeroot \
    git \
    gmp-dev \
    libcurl \
    libffi \
    libffi-dev \
    llvm16 \
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

FROM ghc-base as ghc-stage1

COPY --from=bootstrap-ghc /tmp/ghc-"$GHC_VERSION"/_build/bindist/ghc-"$GHC_VERSION"-*-alpine-linux.tar.xz /tmp/

RUN cd /tmp \
  ## Install GHC
  && tar -xJf ghc-"$GHC_VERSION"-*-alpine-linux.tar.xz \
  && cd ghc-"$GHC_VERSION"-*-alpine-linux \
  && ./configure --disable-ld-override \
  && make install \
  ## Install Stack
  && cd /tmp \
  && curl -sSLO https://github.com/commercialhaskell/stack/releases/download/v"$STACK_VERSION"/stack-"$STACK_VERSION"-linux-"$(uname -m)".tar.gz \
  && curl -sSLO https://github.com/commercialhaskell/stack/releases/download/v"$STACK_VERSION"/stack-"$STACK_VERSION"-linux-"$(uname -m)".tar.gz.sha256 \
  && sha256sum -cs stack-"$STACK_VERSION"-linux-"$(uname -m)".tar.gz.sha256 \
  && tar -xzf stack-"$STACK_VERSION"-linux-"$(uname -m)".tar.gz \
  && mv stack-"$STACK_VERSION"-linux-"$(uname -m)"/stack /usr/local/bin/stack \
  ## Clean up
  && rm -rf /tmp/*

FROM ghc-stage1 as ghc-stage2

## Install Cabal (the tool) built with the GHC bootstrap version
COPY --from=bootstrap-cabal /root/.cabal/bin/cabal /usr/local/bin/cabal

## Rebuild Cabal (the tool) with the GHC target version
RUN cabal update \
  && cabal install "cabal-install-$CABAL_VERSION"

FROM ghc-stage1 as test

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
