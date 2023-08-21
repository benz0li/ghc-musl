ARG GHC_VERSION
ARG STACK_VERSION

ARG STACK_VERSION_UPDATE=${STACK_VERSION}

FROM glcr.b-data.ch/ghc/ghc-musl:${GHC_VERSION}

ARG STACK_VERSION_UPDATE
ARG PREFIX=/usr/local

ENV STACK_VERSION=${STACK_VERSION_UPDATE}

  ## Install Stack
RUN cd /tmp \
  && curl -sSLO https://github.com/commercialhaskell/stack/releases/download/v"$STACK_VERSION"/stack-"$STACK_VERSION"-linux-"$(uname -m)".tar.gz \
  && curl -sSLO https://github.com/commercialhaskell/stack/releases/download/v"$STACK_VERSION"/stack-"$STACK_VERSION"-linux-"$(uname -m)".tar.gz.sha256 \
  && sha256sum -cs stack-"$STACK_VERSION"-linux-"$(uname -m)".tar.gz.sha256 \
  && tar -xzf stack-"$STACK_VERSION"-linux-"$(uname -m)".tar.gz \
  && mv stack-"$STACK_VERSION"-linux-"$(uname -m)"/stack "$PREFIX/bin/stack" \
  ## Clean up
  && rm -rf /tmp/*
