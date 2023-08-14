[![minimal-readme compliant](https://img.shields.io/badge/readme%20style-minimal-brightgreen.svg)](https://github.com/RichardLitt/standard-readme/blob/master/example-readmes/minimal-readme.md) [![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) <a href="https://liberapay.com/benz0li/donate"><img src="https://liberapay.com/assets/widgets/donate.svg" alt="Donate using Liberapay" height="20"></a>

# GHC musl

The multi-arch (`linux/amd64`, `linux/arm64/v8`) docker image used to build the
Linux amd64 and arm64
[binary releases of pandoc](https://github.com/jgm/pandoc/releases).

Credits to

*  [@odidev](https://github.com/odidev) for [ghc-bootstrap-aarch64](https://gitlab.alpinelinux.org/odidev/ghc-bootstrap-aarch64)  
   and
*  [@neosimsim](https://github.com/neosimsim) for
   [docker-builder-images](https://gitlab.com/neosimsim/docker-builder-images)

who laid the groundwork for [this](https://gitlab.com/benz0li/ghc-musl).

## Table of Contents

*  [Prerequisites](#prerequisites)
*  [Install](#install)
*  [Usage](#usage)
*  [Similar projects](#similar-projects)
*  [Contributing](#contributing)
*  [License](#license)

## Prerequisites

This project requires an installation of docker.

## Install

To install docker, follow the instructions for your platform:

*  [Install Docker Engine | Docker Documentation > Supported platforms](https://docs.docker.com/engine/install/#supported-platforms)
*  [Post-installation steps for Linux](https://docs.docker.com/engine/install/linux-postinstall/)

## Usage

### Build image

*latest*:

```bash
docker build \
  --build-arg GHC_VERSION_BUILD=9.6.2 \
  --build-arg CABAL_VERSION_BUILD=3.10.1.0 \
  --build-arg STACK_VERSION=2.11.1 \
  -t ghc-musl \
  -f latest.Dockerfile .
```

*version*:

```bash
docker build \
  -t ghc-musl:MAJOR.MINOR.PATCH \
  -f prior/MAJOR.MINOR.PATCH.Dockerfile .
```

For `MAJOR.MINOR.PATCH` GHC versions `8.8.4`, `8.10.1` and ≥ `8.10.4`.

:point_right: See the [Version Matrix](VERSION_MATRIX.md) for detailed
information.

### Run container

self built:

```bash
docker run --rm -ti ghc-musl[:MAJOR.MINOR.PATCH]
```

from [the project's GitLab Container Registry](https://gitlab.b-data.ch/ghc/ghc-musl/container_registry):

```bash
docker run --rm -ti glcr.b-data.ch/ghc/ghc-musl[:MAJOR[.MINOR[.PATCH]]]
```

As of 2023-08-12, the images (versions 9.2.8, 9.4.6, 9.6.2 and later) also
include the Haskell Tool Stack (Stack).

There is currently no GHC binary distribution for Alpine Linux (AArch64)
available!  
:exclamation: One must use the `--system-ghc --no-install-ghc` flags when using
`stack` with the image for the `arm64/v8` architecture.

## Similar projects

* [utdemir/ghc-musl](https://github.com/utdemir/ghc-musl)
* [fpco/alpine-haskell-stack](https://github.com/fpco/alpine-haskell-stack)

What makes this project different:

1. Multi-arch: `linux/amd64`, `linux/arm64/v8`
1. Built using Hadrian[^1], from source, without docs
1. Built using the LLVM backend
    * flavour: `perf+llvm+split_sections`

[^1]: GHC versions ≥ 9.2.8.

## Contributing

PRs accepted.

This project follows the
[Contributor Covenant](https://www.contributor-covenant.org)
[Code of Conduct](CODE_OF_CONDUCT.md).

## License

[MIT](LICENSE) © 2021 Olivier Benz
