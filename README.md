# Make

All Makefiles have a `make help` command that prints out all the `make ...` commands and their purpose.

All Makefiles have a `make mk-update` command for updating itself to the latest version.

All Makefiles are designed to be used in any organization, in any project, in any environment. No hardcoded org specifics.

## golang.mk

This Makefile was specifically crafted to support the SUDOLESS Golang project and deployment style. It assists in
running, versioning, updating, testing, benchmarking and everything else surrounding Go.

### Features

* Constant and automatic version
  * `v0.2.5-wip4.abaaefd.20210512-dirty+cpl` means that `v0.2.5` was the last tagged commit/version, `-wip4` means we have `4` new commits since `v0.2.5`, `abaaefd` is the current git hash, `20210512` is today's date (`YYYYMMDD`), then we have `-dirty` telling us we have un-committed changes and `+cpl` is the current `whoami` username
* Optimized Go building
* Full support for Go latest module, benchmarking, testing, etc
* Improved Go tooling with easy `make dev-deps` download for developers or CI
* Compilation with `-x` ... `_serviceName, _version, _buildTime, _buildHash`
* Pretty logging
* Structured project (`./cmd/`, `./pkg/`) allowing for `make run-helloworld` to build and run `./cmd/helloworld/...`
* Strict security, performance and styling checks

### TODO

* Add support for multi-module repos
* Add Docker support
* Add deployment integration
* Add changelog management
* Add release management