# GHC musl

<!-- markdownlint-disable line-length -->
[![minimal-readme compliant](https://img.shields.io/badge/readme%20style-minimal-brightgreen.svg)](https://github.com/RichardLitt/standard-readme/blob/master/example-readmes/minimal-readme.md) [![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) <a href="https://liberapay.com/benz0li/donate"><img src="https://liberapay.com/assets/widgets/donate.svg" alt="Donate using Liberapay" height="20"></a> <a href='https://codespaces.new/benz0li/ghc-musl?hide_repo_select=true&ref=main'><img src='https://github.com/codespaces/badge.svg' alt='Open in GitHub Codespaces' height="20" style='max-width: 100%;'></a>
<!-- markdownlint-enable line-length -->

*Unofficial* and *untested* binary distributions of GHC on Alpine Linux.

The multi‑arch (`linux/amd64`, `linux/arm64/v8`) docker image used to build the
*statically linked* Linux amd64 and arm64 binary releases of

* [Pandoc](https://github.com/jgm/pandoc)
* [Stack](https://github.com/commercialhaskell/stack)
* [Juvix](https://github.com/anoma/juvix)

Credit to

* [@odidev](https://github.com/odidev) for
  [ghc-bootstrap-aarch64](https://gitlab.alpinelinux.org/odidev/ghc-bootstrap-aarch64)[^1]  
  and
* [@neosimsim](https://github.com/neosimsim) for
  [neosimsim—Docker build images](https://gitlab.com/neosimsim/docker-builder-images)

[^1]: Porting GHC to Linux/AArch64

who laid the groundwork for [this](https://gitlab.com/benz0li/ghc-musl).

Credit to

* Celeste of Alpine for [GHC bootstrap riscv64](https://gitlab.b-data.ch/ghc/ghc-bootstrap-riscv64)[^2]

who made it possible to add `linux/riscv64` images (GHC versions ≥ 9.10.1).

[^2]: Porting GHC to Linux/RISC-V (64-bit)

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
  -t ghc-musl \
  -f dockerfiles/9.12.2.Dockerfile .
```

*version*:

```bash
docker build \
  -t ghc-musl:MAJOR.MINOR.PATCH \
  -f dockerfiles/MAJOR.MINOR.PATCH.Dockerfile .
```

For `MAJOR.MINOR.PATCH` GHC versions `8.8.4`, `8.10.1` and ≥ `8.10.4`.

:point_right: See the [Version Matrix](VERSION_MATRIX.md) for detailed
information.

### Run container

self built:

```bash
docker run --rm -ti ghc-musl:{latest,MAJOR.MINOR.PATCH}
```

from [Quay](https://quay.io/repository/benz0li/ghc-musl):

```bash
docker run --rm -ti quay.io/benz0li/ghc-musl:{latest,MAJOR[.MINOR[.PATCH]]}[-int-native]
```

from [Docker Hub](https://hub.docker.com/r/benz0li/ghc-musl):

```bash
docker run --rm -ti docker.io/benz0li/ghc-musl:{latest,MAJOR[.MINOR[.PATCH]]}[-int-native]
```

from [GitLab (b-data GmbH)](https://gitlab.b-data.ch/ghc/ghc-musl/container_registry/381):

```bash
docker run --rm -ti glcr.b-data.ch/ghc/ghc-musl:{latest,MAJOR[.MINOR[.PATCH]]}[-int-native]
```

As of 2023‑08‑12, the images (versions 9.2.8, 9.4.6, 9.6.2 and later) also
include the Haskell Tool Stack (Stack).

On 2024‑02‑23, the binary distribution of GHC version 9.8.2 was released for
Alpine Linux (AArch64).  
:exclamation: Use flags <nobr>`--no-install-ghc --system-ghc`</nobr> with
Stack (GHC versions < 9.8.2) to ensure that only the GHC available in the
container is used.

#### GMP licensing restrictions

The regular images produce binaries linked against the
[GNU Multiple Precision Arithmetic Library (GMP)](https://gmplib.org/), which
is used by default by the
[`integer-gmp`](https://hackage.haskell.org/package/integer-gmp) library to
provide a big-integer implementation for Haskell.

Unlike most Haskell code, which is licensed under the permissive BSD3 license,
the GMP library is licensed under LGPL. This means resulting
*statically linked* binaries [must be provided with source code or object files](http://www.gnu.org/licenses/gpl-faq.html#LGPLStaticVsDynamic).

If that is not acceptable for your situation, use images with the `int-native`
subtag. These images provide a GHC that links against the Haskell-native
big-integer backend and produces *statically linked* binaries that are not
subject to GMP's licensing restrictions.  
:information_source: Available for versions 9.6.7, 9.8.4, 9.10.1, 9.12.2 and
later.

#### Default linker

All images use `ld.bfd` (the GNU linker) by default. Regarding `ld.lld` (the
LLVM linker) see issue <https://github.com/benz0li/ghc-musl/issues/13>.

### Dev Containers

The default Dev Container is meant to work on this repository.

Any other configuration is a custom GHC container based on
<nobr>*GHC musl*</nobr>.

For further information, see [Dev Containers](.devcontainer).

## Similar projects

* [utdemir/ghc-musl](https://github.com/utdemir/ghc-musl)
* [fpco/alpine-haskell-stack](https://github.com/fpco/alpine-haskell-stack)

What makes this project different:

1. Multi‑arch: `linux/amd64`, `linux/arm64/v8`
1. Built using Hadrian[^3], from source, without docs
1. Built using the LLVM backend. Flavours:
    * regular images: `perf+split_sections+llvm`
    * `int-native` subtag: `perf+split_sections+llvm+native_bignum`

[^3]: GHC versions ≥ 9.2.8.

Interesting to read:

* [Improving Haskell’s big numbers support](https://iohk.io/en/blog/posts/2020/07/28/improving-haskells-big-numbers-support)
  by [@hsyl20](https://github.com/hsyl20)
* [lsupg Static Builds With GHC 9](https://www.extrema.is/blog/2023/02/04/lsupg-static-builds-with-ghc-9)
  by [@TravisCardwell](https://github.com/TravisCardwell)
  * especially [Part 2](https://www.extrema.is/blog/2024/04/20/lsupg-static-builds-with-ghc-9-part-2)
    and [Part 3](https://www.extrema.is/blog/2024/04/22/lsupg-static-builds-with-ghc-9-part-3)

## Contributing

PRs accepted. Please submit to the
[GitLab repository](https://gitlab.com/benz0li/ghc-musl).

This project follows the
[Contributor Covenant](https://www.contributor-covenant.org)
[Code of Conduct](CODE_OF_CONDUCT.md).

## License

Copyright © 2021 Olivier Benz

Distributed under the terms of the [MIT License](LICENSE).
