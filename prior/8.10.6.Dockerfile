ARG GHC_VERSION_BUILD
ARG CABAL_VERSION_BUILD

FROM registry.gitlab.b-data.ch/ghc/ghc4pandoc:8.8.4 as bootstrap

ENV GHC_VERSION=${GHC_VERSION_BUILD:-8.10.6}
ENV CABAL_VERSION=${CABAL_VERSION_BUILD:-3.2.0.0}

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

RUN cd /tmp \
  && curl -sSLO https://downloads.haskell.org/~ghc/$GHC_VERSION/ghc-$GHC_VERSION-src.tar.xz \
  && curl -sSLO https://downloads.haskell.org/~ghc/$GHC_VERSION/ghc-$GHC_VERSION-src.tar.xz.sig \
  && gpg --keyserver hkps://pgp.mit.edu:443 \
    --receive-keys 588764FBE22D19C4 \
  && gpg --verify ghc-$GHC_VERSION-src.tar.xz.sig ghc-$GHC_VERSION-src.tar.xz \
  && tar xf ghc-$GHC_VERSION-src.tar.xz \
  && cd ghc-$GHC_VERSION \
  # Set llvm version to 10
  && sed -i -e 's/LlvmVersion=9/LlvmVersion=10/g' configure.ac \
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
  && make -j$((`nproc`+1)) \
  && make binary-dist \
  && cabal update \
  # See https://gitlab.haskell.org/ghc/ghc/-/wikis/commentary/libraries/version-history
  && cabal install cabal-install-$CABAL_VERSION

FROM alpine:3.13 as builder

LABEL org.label-schema.license="MIT" \
      org.label-schema.vcs-url="https://gitlab.b-data.ch/ghc/ghc4pandoc" \
      maintainer="Olivier Benz <olivier.benz@b-data.ch>"

ENV GHC_VERSION=${GHC_VERSION_BUILD:-8.10.6}
ENV CABAL_VERSION=${CABAL_VERSION_BUILD:-3.2.0.0}

RUN apk add --update --no-cache \
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
    llvm10 \
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
  && cd / \
  && rm -rf /tmp/*

FROM builder as tester

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