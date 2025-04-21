## Supported Versions

The docker images with the three latest major versions of GHC – plus the
version I consider *recommended*[^1] – are supported with security updates.

[^1]: See [Dev Containers > Version Matrix](.devcontainer/VERSION_MATRIX.md).
Possibly newer than [the version recommended by GHCup](https://www.haskell.org/ghcup/install/#supported-tools).

`linux/riscv64` docker images are currently built only once. Therefore,
vulnerabilities for this `os/arch` will not be fixed.

## Reporting a Vulnerability

To report a vulnerability in a latest docker image, email the maintainer
<olivier.benz@b-data.ch>.

## Vulnerabilities in Prior Versions

Vulnerabilities in docker images with prior versions of GHC are not fixed.

Whenever a new version of GHC is released, the previous version's docker image
is rebuilt once again and then frozen.
