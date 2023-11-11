ARG GHC_VERSION=9.6.3
ARG CABAL_VERSION=3.10.1.0
ARG STACK_VERSION=2.13.1

ARG GHC_VERSION_BUILD=${GHC_VERSION}
ARG CABAL_VERSION_BUILD=${CABAL_VERSION}

FROM glcr.b-data.ch/ghc/ghc-musl:9.4.7 as bootstrap

ARG GHC_VERSION_BUILD
ARG CABAL_VERSION_BUILD

ENV GHC_VERSION=${GHC_VERSION_BUILD} \
    CABAL_VERSION=${CABAL_VERSION_BUILD}

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
    llvm14 \
    ncurses-dev \
    perl \
    python3 \
    xz \
    zlib-dev

RUN cd /tmp \
  && curl -sSLO https://downloads.haskell.org/~ghc/"$GHC_VERSION"/ghc-"$GHC_VERSION"-src.tar.xz \
  && curl -sSLO https://downloads.haskell.org/~ghc/"$GHC_VERSION"/ghc-"$GHC_VERSION"-src.tar.xz.sig \
  && gpg --keyserver hkps://keyserver.ubuntu.com:443 \
    --receive-keys 33C3A599DB85EA9B8BAA1866B202264020068BFB || \
    gpg --keyserver hkp://keyserver.ubuntu.com:80 \
    --receive-keys 33C3A599DB85EA9B8BAA1866B202264020068BFB \
  && gpg --verify "ghc-$GHC_VERSION-src.tar.xz.sig" "ghc-$GHC_VERSION-src.tar.xz" \
  && tar -xJf "ghc-$GHC_VERSION-src.tar.xz" \
  && cd "ghc-$GHC_VERSION" \
  && ./boot.source \
  && ./configure --disable-ld-override LD=ld.gold \
  # Use the LLVM backend
  # Switch llvm-targets from unknown-linux-gnueabihf->alpine-linux
  # so we can match the llvm vendor string alpine uses
  && sed -i -e 's/unknown-linux-gnueabihf/alpine-linux/g' llvm-targets \
  && sed -i -e 's/unknown-linux-gnueabi/alpine-linux/g' llvm-targets \
  && sed -i -e 's/unknown-linux-gnu/alpine-linux/g' llvm-targets \
  && cabal update \
  # See https://unix.stackexchange.com/questions/519092/what-is-the-logic-of-using-nproc-1-in-make-command
  && hadrian/build binary-dist -j"$(($(nproc)+1))" \
    --flavour=perf+llvm+split_sections \
    --docs=none \
  # See https://gitlab.haskell.org/ghc/ghc/-/wikis/commentary/libraries/version-history
  && cabal install --allow-newer --constraint 'Cabal-syntax<3.11' "cabal-install-$CABAL_VERSION"

FROM alpine:3.18 as builder

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
    llvm14 \
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

COPY --from=bootstrap /tmp/ghc-"$GHC_VERSION"/_build/bindist/ghc-"$GHC_VERSION"-*-alpine-linux.tar.xz /tmp/

RUN cd /tmp \
  # Fix https://github.com/haskell/cabal/issues/8923
  && PKG_CONFIG_VERSION="$(pkg-config --version)" \
  && if [ "${PKG_CONFIG_VERSION%.*}" = "1.9" ]; then \
    # Downgrade pkgconf from 1.9.x to 1.8.1
    curl -sSLO http://dl-cdn.alpinelinux.org/alpine/v3.16/main/"$(uname -m)"/pkgconf-1.8.1-r0.apk; \
    apk add --no-cache pkgconf-1.8.1-r0.apk; \
  fi \
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

## Install Cabal
COPY --from=bootstrap /root/.cabal/bin/cabal /usr/local/bin/cabal

FROM builder as test

WORKDIR /usr/local/src

COPY Main.hs Main.hs

RUN ghc -static -optl-pthread -optl-static Main.hs \
  && file Main \
  && ./Main \
  # Test cabal workflow
  && mkdir cabal-test \
  && cd cabal-test \
  && cabal update \
  && cabal init -n --is-executable -p tester -l MIT \
  && cabal run

FROM builder as final

CMD ["ghci"]
