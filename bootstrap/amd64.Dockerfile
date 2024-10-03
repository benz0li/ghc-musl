ARG GHC_VERSION=8.8.3
ARG CABAL_VERSION=3.2.0.0

ARG GHC_VERSION_BUILD=${GHC_VERSION}
ARG CABAL_VERSION_BUILD=${CABAL_VERSION}

FROM alpine:3.12 AS bootstrap

ARG CABAL_VERSION_BUILD

ENV CABAL_VERSION=${CABAL_VERSION_BUILD}

COPY ghc-8.8.patch /tmp/
COPY cabal-0001-force-ld.gold.patch /tmp/

RUN apk add --no-cache \
    autoconf \
    automake \
    binutils-gold \
    build-base \
    coreutils \
    cpio \
    curl \
    ghc \
    gnupg \
    linux-headers \
    libffi-dev \
    ncurses-dev \
    perl \
    python3 \
    xz \
    zlib-dev

RUN cd /tmp/ \
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

ARG GHC_VERSION_BUILD
ARG CABAL_VERSION_BUILD

ENV GHC_VERSION=${GHC_VERSION_BUILD}
ENV CABAL_VERSION=${CABAL_VERSION_BUILD}

RUN apk add --no-cache \
    bash \
    build-base \
    bzip2 \
    bzip2-dev \
    #bzip2-static \
    curl \
    curl-static \
    fakeroot \
    ghc \
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
    zlib-dev
    #zlib-static

COPY --from=bootstrap /root/.cabal/bin/cabal /usr/bin/cabal

CMD ["ghci"]
