# Version Matrix

Topmost entry = Tag `latest`

| GHC        | Cabal    | Stack      | LLVM | Linux distro |
|:-----------|:---------|:-----------|:---- |:-------------|
| 9.12.2     | 3.14.1.1 | 3.3.1      | 18   | Alpine 3.21  |
| 9.12.1     | 3.14.1.0 | 3.3.1      | 18   | Alpine 3.21  |
| 9.10.1     | 3.12.1.0 | 3.3.1      | 18   | Alpine 3.21  |
| 9.8.4      | 3.10.3.0 | 3.3.1      | 16   | Alpine 3.21  |
| 9.8.3      | 3.10.3.0 | 3.1.1      | 16   | Alpine 3.20  |
| 9.8.2      | 3.10.3.0 | 3.1.1      | 16   | Alpine 3.20  |
| 9.8.1      | 3.10.2.1 | 2.15.1     | 14   | Alpine 3.19  |
| 9.6.7      | 3.10.3.0 | 3.3.1      | 16   | Alpine 3.21  |
| 9.6.6      | 3.10.3.0 | 3.3.1      | 16   | Alpine 3.21  |
| 9.6.5      | 3.10.3.0 | 2.15.7     | 16   | Alpine 3.20  |
| 9.6.4      | 3.10.3.0 | 2.15.5     | 14   | Alpine 3.19  |
| 9.6.3      | 3.10.1.0 | 2.13.1     | 14   | Alpine 3.19  |
| 9.6.2      | 3.10.1.0 | 2.11.1[^1] | 14   | Alpine 3.18  |
| 9.6.1      | 3.10.1.0 | n/a        | 14   | Alpine 3.18  |
| 9.4.8      | 3.8.1.0  | 2.15.7     | 14   | Alpine 3.19  |
| 9.4.7      | 3.8.1.0  | 2.13.1     | 14   | Alpine 3.18  |
| 9.4.6      | 3.8.1.0  | 2.11.1[^1] | 14   | Alpine 3.18  |
| 9.4.5      | 3.8.1.0  | n/a        | 14   | Alpine 3.17  |
| 9.4.4      | 3.8.1.0  | n/a        | 14   | Alpine 3.17  |
| 9.4.3      | 3.8.1.0  | n/a        | 12   | Alpine 3.16  |
| 9.4.2      | 3.8.1.0  | n/a        | 12   | Alpine 3.16  |
| 9.4.1      | 3.8.1.0  | n/a        | 12   | Alpine 3.16  |
| 9.2.8      | 3.6.2.0  | 2.15.7     | 12   | Alpine 3.16  |
| 9.2.7[^2]  | 3.6.2.0  | n/a        | 12   | Alpine 3.16  |
| 9.2.6[^2]  | 3.6.2.0  | n/a        | 12   | Alpine 3.16  |
| 9.2.5[^2]  | 3.6.2.0  | n/a        | 12   | Alpine 3.16  |
| 9.2.4[^2]  | 3.6.2.0  | n/a        | 12   | Alpine 3.16  |
| 9.2.3[^2]  | 3.6.2.0  | n/a        | 12   | Alpine 3.16  |
| 9.2.2[^2]  | 3.6.2.0  | n/a        | 12   | Alpine 3.16  |
| 9.2.1[^2]  | 3.6.0.0  | n/a        | 12   | Alpine 3.15  |
| 9.0.2[^2]  | 3.4.0.0  | n/a        | 10   | Alpine 3.15  |
| 9.0.1[^2]  | 3.4.0.0  | n/a        | 10   | Alpine 3.15  |
| 8.10.7[^2] | 3.2.0.0  | n/a        | 10   | Alpine 3.13  |
| 8.10.6[^2] | 3.2.0.0  | n/a        | 10   | Alpine 3.13  |
| 8.10.5[^2] | 3.2.0.0  | n/a        | 10   | Alpine 3.13  |
| 8.10.4[^2] | 3.2.0.0  | n/a        | 10   | Alpine 3.13  |
| 8.10.1[^2] | 3.2.0.0  | n/a        | 10   | Alpine 3.13  |
| 8.8.4[^2]  | 3.2.0.0  | n/a        | 10   | Alpine 3.12  |

[^1]: unsupported build; *statically linked* binary  
[^2]: w/o Haddock; due to `HADDOCK_DOCS=NO`

## Broken releases

* GHC 9.12.1
  * Official statement: <https://discourse.haskell.org/t/psa-correctness-issue-in-ghc-9-12/11204>
  * GitLab issue: <https://gitlab.haskell.org/ghc/ghc/-/issues/25653>
* GHC 9.2.1
  * Official statement: <https://discourse.haskell.org/t/psa-9-2-1-aarch64-miscompilation/3638>
  * GitLab issues: See <https://gitlab.haskell.org/ghc/ghc/-/merge_requests/6934>

## Bugs

\-

## Bug fixes

* Images based on Alpine 3.{17,18}: Package pkgconf downgraded to v1.8.1
  * Due to <https://github.com/haskell/cabal/issues/8923>
* `linux/riscv64` image for GHC version 9.12.1 built with
  `--flavour=quick+llvm`
  * Due to <https://gitlab.haskell.org/ghc/ghc/-/issues/25594>

## Experimental

`linux/riscv64` images for GHC versions ≥ 9.10.1, e.g.
`quay.io/benz0li/ghc-musl:{latest,GHC_VERSION}-linux-riscv64`.  
:information_source: Whenever a new version of GHC is released, the previous
`linux/riscv64` image is added to the manifest.
