# GHC musl

<!-- markdownlint-disable line-length -->
[![minimal-readme compliant](https://img.shields.io/badge/readme%20style-minimal-brightgreen.svg)](https://github.com/RichardLitt/standard-readme/blob/master/example-readmes/minimal-readme.md) [![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) <a href="https://liberapay.com/benz0li/donate"><img src="https://liberapay.com/assets/widgets/donate.svg" alt="Donate using Liberapay" height="20"></a> <a href='https://codespaces.new/benz0li/ghc-musl?hide_repo_select=true&ref=main'><img src='https://github.com/codespaces/badge.svg' alt='Open in GitHub Codespaces' height="20" style='max-width: 100%;'></a>
<!-- markdownlint-enable line-length -->

Unofficial binary distributions of GHC on Alpine Linux.

The multi‑arch (`linux/amd64`, `linux/arm64/v8`) docker image used to build the
*statically linked* Linux amd64 and arm64 binary releases of

* [Pandoc](https://github.com/jgm/pandoc)
* [Stack](https://github.com/commercialhaskell/stack)
* [Juvix](https://github.com/anoma/juvix)

Credits to

<!-- markdownlint-disable line-length -->
* [@odidev](https://github.com/odidev) for
  [ghc-bootstrap-aarch64](https://gitlab.alpinelinux.org/odidev/ghc-bootstrap-aarch64)  
   and
* [@neosimsim](https://github.com/neosimsim) for
  [docker-builder-images](https://gitlab.com/neosimsim/docker-builder-images)
<!-- markdownlint-enable line-length -->

who laid the groundwork for [this](https://gitlab.com/benz0li/ghc-musl).

## Table of Contents

* [Prerequisites](#prerequisites)
* [Install](#install)
* [Usage](#usage)
* [Similar projects](#similar-projects)
* [Contributing](#contributing)
* [License](#license)

## Prerequisites

This project requires an installation of docker.

## Install

To install docker, follow the instructions for your platform:

* [Install Docker Engine | Docker Documentation > Supported platforms](https://docs.docker.com/engine/install/#supported-platforms)
* [Post-installation steps for Linux](https://docs.docker.com/engine/install/linux-postinstall/)

## Usage

### Build image

*latest*:

```bash
docker build \
  --build-arg GHC_VERSION=9.8.2 \
  --build-arg CABAL_VERSION=3.10.2.1 \
  --build-arg STACK_VERSION=2.15.1 \
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

from [Quay](https://quay.io/repository/benz0li/ghc-musl):

```bash
docker run --rm -ti quay.io/benz0li/ghc-musl[:MAJOR[.MINOR[.PATCH]]]
```

from [Docker Hub](https://hub.docker.com/r/benz0li/ghc-musl):

```bash
docker run --rm -ti docker.io/benz0li/ghc-musl[:MAJOR[.MINOR[.PATCH]]]
```

from [GitLab (b-data GmbH)](https://gitlab.b-data.ch/ghc/ghc-musl/container_registry/381):

```bash
docker run --rm -ti glcr.b-data.ch/ghc/ghc-musl[:MAJOR[.MINOR[.PATCH]]]
```

As of 2023‑08‑12, the images (versions 9.2.8, 9.4.6, 9.6.2 and later) also
include the Haskell Tool Stack (Stack).

There is currently no GHC binary distribution for Alpine Linux (AArch64)
available!  
:exclamation: Use flags <nobr>`--no-install-ghc --system-ghc`</nobr> with
Stack to ensure that only the GHC available in the container is used.

### Dev Containers

The default Dev Container is meant to work on this repository.

Any other configuration is a custom GHC container based on
<nobr>*GHC musl*</nobr>.

For further information, see [Dev Containers](.devcontainer/README.md).

## Similar projects

* [utdemir/ghc-musl](https://github.com/utdemir/ghc-musl)
* [fpco/alpine-haskell-stack](https://github.com/fpco/alpine-haskell-stack)

What makes this project different:

1. Multi‑arch: `linux/amd64`, `linux/arm64/v8`
1. Built using Hadrian[^1], from source, without docs
1. Built using the LLVM backend
    * flavour: `perf+llvm+split_sections`

[^1]: GHC versions ≥ 9.2.8.

## Contributing

PRs accepted. Please submit to the
[GitLab repository](https://gitlab.com/benz0li/ghc-musl).

This project follows the
[Contributor Covenant](https://www.contributor-covenant.org)
[Code of Conduct](CODE_OF_CONDUCT.md).

## License

[MIT](LICENSE) © 2021 Olivier Benz
