## Supported Versions

Only the docker images with the latest version of GHC are supported with
security updates.

`linux/riscv64` docker images are currently built only once. Therefore,
vulnerabilities for this `os/arch` will not be fixed.

## Reporting a Vulnerability

To report a vulnerability in a latest docker image, email the maintainer
<olivier.benz@b-data.ch>.

## Vulnerabilities in Prior Versions

Vulnerabilities in docker images with prior versions of GHC are not fixed.

Whenever a new version of GHC is released, the previous version's docker image
is rebuilt once again and then frozen.
