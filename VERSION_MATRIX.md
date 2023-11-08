# Version Matrix

Topmost entry = Tag `latest`

| GHC        | Cabal    | Stack      | LLVM | Linux distro |
|:-----------|:---------|:-----------|:---- |:-------------|
| 9.8.1      | 3.10.2.1 | 2.13.1     | 14   | Alpine 3.18  |
| 9.6.3      | 3.10.1.0 | 2.13.1     | 14   | Alpine 3.18  |
| 9.6.2      | 3.10.1.0 | 2.11.1[^1] | 14   | Alpine 3.18  |
| 9.6.1      | 3.10.1.0 | n/a        | 14   | Alpine 3.18  |
| 9.4.7      | 3.8.1.0  | 2.13.1     | 14   | Alpine 3.18  |
| 9.4.6      | 3.8.1.0  | 2.11.1[^1] | 14   | Alpine 3.18  |
| 9.4.5      | 3.8.1.0  | n/a        | 14   | Alpine 3.17  |
| 9.4.4      | 3.8.1.0  | n/a        | 14   | Alpine 3.17  |
| 9.4.3      | 3.8.1.0  | n/a        | 12   | Alpine 3.16  |
| 9.4.2      | 3.8.1.0  | n/a        | 12   | Alpine 3.16  |
| 9.4.1      | 3.8.1.0  | n/a        | 12   | Alpine 3.16  |
| 9.2.8      | 3.6.2.0  | 2.13.1     | 12   | Alpine 3.16  |
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

## Bug fixes

* Images based on Alpine 3.{17,18}: Package pkgconf downgraded to v1.8.1
  * Due to https://github.com/haskell/cabal/issues/8923
