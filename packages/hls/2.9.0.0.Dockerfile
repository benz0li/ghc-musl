ARG GHC_VERSION
ARG HLS_VERSION=2.9.0.0

FROM glcr.b-data.ch/ghc/ghc-musl:${GHC_VERSION} AS builder

ARG HLS_VERSION

RUN apk add --no-cache patchelf findutils \
  && cd /tmp \
  && curl -sSL "https://github.com/haskell/haskell-language-server/archive/refs/tags/$HLS_VERSION.tar.gz" \
    -o "haskell-language-server-$HLS_VERSION.tar.gz" \
  && tar -xzf "haskell-language-server-$HLS_VERSION.tar.gz" \
  && cd "haskell-language-server-$HLS_VERSION" \
  && . .github/scripts/env.sh \
  && . .github/scripts/common.sh \
  && sed -i.bak -e '/DELETE MARKER FOR CI/,/END DELETE/d' cabal.project \
  && GHCS="$GHC_VERSION" \
  && export GHCS \
  && ARTIFACT="$(uname -m)-linux-alpine" \
  && export ARTIFACT \
  && cabal update \
  && emake hls-ghc \
  && CABAL_VERSION_NUMERIC="$(cabal --numeric-version)" \
  && if dpkg --compare-versions "${CABAL_VERSION_NUMERIC%.*.*}" ge "3.11"; then \
    sed -i 's|"$(STORE_DIR)/ghc-$(GHC_VERSION)"|"$(STORE_DIR)/ghc-$(GHC_VERSION)-inplace"|g' \
      GNUmakefile; \
  fi \
  && emake bindist \
  && strip "out/bindist/$ARTIFACT/haskell-language-server-$HLS_VERSION/lib/$GHC_VERSION"/*.so \
  && emake bindist-tar

FROM alpine:3.21 AS hls

ARG HLS_VERSION

COPY --from=builder /tmp/haskell-language-server-"$HLS_VERSION"/out/haskell-language-server-*-linux-alpine.tar.xz /tmp/

RUN apk add --no-cache build-base \
  && cd /tmp \
  && tar -xJf haskell-language-server-"$HLS_VERSION"-*-linux-alpine.tar.xz \
  && cd haskell-language-server-"$HLS_VERSION" \
  && make install

FROM scratch

ARG HLS_VERSION

ENV HLS_VERSION=${HLS_VERSION}

COPY --from=hls /usr/local /usr/local
