ARG GHC_VERSION_BUILD
ARG CABAL_VERSION_BUILD

FROM alpine:3.12 as bootstrap

ENV CABAL_VERSION=${CABAL_VERSION_BUILD:-3.2.0.0}

COPY ghc-8.8.patch /tmp/
COPY cabal-0001-force-ld.gold.patch /tmp/

RUN apk add --update --no-cache \
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
    ncurses-dev \
    perl \
    python3 \
    xz \
    zlib-dev

RUN cd /tmp/ \
  && wget https://gitlab.b-data.ch/ghc/ghc-bootstrap-aarch64/-/raw/main/ghc-8.8.3-r0.apk \
  && apk add --allow-untrusted ghc-8.8.3-r0.apk \
  && curl -sSLO https://downloads.haskell.org/~cabal/cabal-install-$CABAL_VERSION/cabal-install-$CABAL_VERSION.tar.gz \
  && tar zxf cabal-install-$CABAL_VERSION.tar.gz \
  && cd /tmp/cabal-install-$CABAL_VERSION/ \
  && patch < /tmp/ghc-8.8.patch \
  && patch < /tmp/cabal-0001-force-ld.gold.patch \
  && EXTRA_CONFIGURE_OPTS="" ./bootstrap.sh --jobs --no-doc

FROM alpine:3.12

LABEL org.label-schema.license="MIT" \
      org.label-schema.vcs-url="https://gitlab.b-data.ch/ghc/ghc4pandoc" \
      maintainer="Olivier Benz <olivier.benz@b-data.ch>"

ENV GHC_VERSION=${GHC_VERSION_BUILD:-8.8.3}
ENV CABAL_VERSION=${CABAL_VERSION_BUILD:-3.2.0.0}

RUN apk add --update --no-cache \
    bash \
    build-base \
    bzip2 \
    bzip2-dev \
    #bzip2-static \
    curl \
    curl-static \
    fakeroot \
    git \
    gmp-dev \
    libcurl \
    libffi \
    libffi-dev \
    ncurses-dev \
    ncurses-static \
    openssl-dev \
    #openssl-libs-static \
    pcre \
    pcre-dev \
    pcre2 \
    pcre2-dev \
    perl \
    wget \
    xz \
    xz-dev \
    zlib \
    zlib-dev \
    #zlib-static \
  && cd /tmp/ \
  && wget https://gitlab.b-data.ch/ghc/ghc-bootstrap-aarch64/-/raw/main/ghc-8.8.3-r0.apk \
  && apk add --allow-untrusted ghc-8.8.3-r0.apk \
  && cd / \
  && rm -rf /tmp/*

COPY --from=bootstrap /root/.cabal/bin/cabal /usr/bin/cabal
