ARG GHC_VERSION=9.2.1
ARG CABAL_VERSION=3.6.0.0

ARG GHC_VERSION_BUILD=${GHC_VERSION}
ARG CABAL_VERSION_BUILD=${CABAL_VERSION}

FROM registry.gitlab.b-data.ch/ghc/ghc4pandoc:9.0.2 as bootstrap

COPY patches/* /tmp/

ARG GHC_VERSION_BUILD
ARG CABAL_VERSION_BUILD

ENV GHC_VERSION=${GHC_VERSION_BUILD}
ENV CABAL_VERSION=${CABAL_VERSION_BUILD}

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
    llvm12 \
    ncurses-dev \
    perl \
    python3 \
    xz \
    zlib-dev

RUN cd /tmp \
  && curl -sSLO https://downloads.haskell.org/~ghc/$GHC_VERSION/ghc-$GHC_VERSION-src.tar.xz \
  && curl -sSLO https://downloads.haskell.org/~ghc/$GHC_VERSION/ghc-$GHC_VERSION-src.tar.xz.sig \
  && gpg --keyserver hkps://keyserver.ubuntu.com:443 \
    --receive-keys FFEB7CE81E16A36B3E2DED6F2DE04D4E97DB64AD || \
    gpg --keyserver hkp://keyserver.ubuntu.com:80 \
    --receive-keys FFEB7CE81E16A36B3E2DED6F2DE04D4E97DB64AD \
  && gpg --verify ghc-$GHC_VERSION-src.tar.xz.sig ghc-$GHC_VERSION-src.tar.xz \
  && tar xf ghc-$GHC_VERSION-src.tar.xz \
  && cd ghc-$GHC_VERSION \
  # Apply patches
  && mv /tmp/*.patch . \
  && patch -p0 <ghc-9.2.1-RtsSymbols.patch \
  # Use the LLVM backend
  && cp mk/build.mk.sample mk/build.mk \
  && echo 'BuildFlavour=perf-llvm' >> mk/build.mk \
  && echo 'BeConservative=YES' >> mk/build.mk \
  && echo 'SplitSections=YES' >> mk/build.mk \
  && echo 'HADDOCK_DOCS=NO' >> mk/build.mk \
  && echo 'HSCOLOUR_SRCS=NO' >> mk/build.mk \
  && echo 'BUILD_SPHINX_HTML=NO' >> mk/build.mk \
  && echo 'BUILD_SPHINX_PS=NO' >> mk/build.mk \
  && echo 'BUILD_SPHINX_PDF=NO' >> mk/build.mk \
  && autoreconf \
  && ./configure --disable-ld-override LD=ld.gold \
  # Switch llvm-targets from unknown-linux-gnueabihf->alpine-linux
  # so we can match the llvm vendor string alpine uses
  && sed -i -e 's/unknown-linux-gnueabihf/alpine-linux/g' llvm-targets \
  && sed -i -e 's/unknown-linux-gnueabi/alpine-linux/g' llvm-targets \
  && sed -i -e 's/unknown-linux-gnu/alpine-linux/g' llvm-targets \
  # See https://unix.stackexchange.com/questions/519092/what-is-the-logic-of-using-nproc-1-in-make-command
  && make -j"$(($(nproc)+1))" \
  && make binary-dist \
  && cabal update \
  # See https://gitlab.haskell.org/ghc/ghc/-/wikis/commentary/libraries/version-history
  && cabal install --allow-newer --constraint 'Cabal-syntax<3.7' cabal-install-$CABAL_VERSION

FROM alpine:3.15 as builder

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
    llvm12 \
    ncurses-dev \
    ncurses-static \
    openssl-dev \
    openssl-libs-static \
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
    zlib-static

COPY --from=bootstrap /tmp/ghc-$GHC_VERSION/ghc-$GHC_VERSION-*-alpine-linux.tar.xz /tmp/
COPY --from=bootstrap /root/.cabal/bin/cabal /usr/bin/cabal

RUN cd /tmp \
  && tar -xJf ghc-$GHC_VERSION-*-alpine-linux.tar.xz \
  && cd ghc-$GHC_VERSION \
  && ./configure --disable-ld-override --prefix=/usr \
  && make install \
  && rm -rf /tmp/*

FROM builder as tester

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
