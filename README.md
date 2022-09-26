[![minimal-readme compliant](https://img.shields.io/badge/readme%20style-minimal-brightgreen.svg)](https://github.com/RichardLitt/standard-readme/blob/master/example-readmes/minimal-readme.md) [![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) <a href="https://liberapay.com/benz0li/donate"><img src="https://liberapay.com/assets/widgets/donate.svg" alt="Donate using Liberapay" height="20"></a> <a href="https://benz0li.b-data.io/donate?project=1"><img src="https://benz0li.b-data.io/donate/static/donate-with-fosspay.png" alt="Donate with fosspay"></a>

# GHC for pandoc

The multi-arch (`linux/amd64`, `linux/arm64/v8`) docker image used to build the
Linux amd64 and arm64 binary
[releases of pandoc](https://github.com/jgm/pandoc/releases).

Credits to

*  [@odidev](https://github.com/odidev) for [ghc-bootstrap-aarch64](https://gitlab.alpinelinux.org/odidev/ghc-bootstrap-aarch64)  
   and
*  [@neosimsim](https://github.com/neosimsim) for
   [docker-builder-images](https://gitlab.com/neosimsim/docker-builder-images)

who laid the groundwork for [this](https://gitlab.b-data.ch/ghc/ghc4pandoc).

## Table of Contents

*  [Prerequisites](#prerequisites)
*  [Install](#install)
*  [Usage](#usage)
*  [Similar project](#similar-project)
*  [Contributing](#contributing)
*  [License](#license)

## Prerequisites

This projects requires an installation of docker.

## Install

To install docker, follow the instructions for your platform:

*  [Install Docker Engine | Docker Documentation > Supported platforms](https://docs.docker.com/engine/install/#supported-platforms)
*  [Post-installation steps for Linux](https://docs.docker.com/engine/install/linux-postinstall/)

## Usage

### Build image

latest:

```bash
docker build \
  --build-arg GHC_VERSION_BUILD=9.4.2 \
  --build-arg CABAL_VERSION_BUILD=3.8.1.0 \
  -t ghc4pandoc \
  -f latest.Dockerfile .
```

version:

```bash
docker build \
  -t ghc4pandoc:<major>.<minor>.<patch> \
  -f <major>.<minor>.<patch>.Dockerfile .
```

For `<major>.<minor>.<patch>` GHC versions `8.8.4`, `8.10.1` and ≥ `8.10.4`.

### Run container

self built:

```bash
docker run --rm -ti ghc4pandoc[:<major>.<minor>.<patch>]
```

from [the project's GitLab Container Registry](https://gitlab.b-data.ch/ghc/ghc4pandoc/container_registry):

```bash
docker run --rm -ti registry.gitlab.b-data.ch/ghc/ghc4pandoc[:<major>[.<minor>[.<patch>]]]
```

## Similar project

* [utdemir/ghc-musl](https://github.com/utdemir/ghc-musl)

## Contributing

PRs accepted.

This project follows the
[Contributor Covenant](https://www.contributor-covenant.org)
[Code of Conduct](CODE_OF_CONDUCT.md).

## License

[MIT](LICENSE) © 2021 Olivier Benz
