# Make

All Makefiles have a `make help` command that prints out all the `make ...` commands and their purpose.

All Makefiles have a `make mk-update` command for updating itself to the latest version.

All Makefiles are designed to be used in any organization, in any project, in any environment. No hardcoded org specifics.
But certain aspects may be tailored to SUDOLESS needs.

General Makefile features include:

* Constant and automatic version
  * `v0.2.5-wip4.abaaefd-dirty.20210512.cpl` means that `v0.2.5` was the last tagged commit/version, `-wip4` means we have `4` new commits since `v0.2.5`, `abaaefd` is the current git hash, `20210512` is today's date (`YYYYMMDD`), then we have `-dirty` telling us we have un-committed changes and `cpl` is the current `whoami` username
* Pretty logging
* Support for user/local defined make commands (using `#### CUSTOM` delimiter)
* Easy updates with `make mk-update`
* Modular and extensible design, using the imports system
  * Define a project directory (default: `./make`) where other makefiles are stored
  * Call `make import_makefile_name/rule`, to call a `rule` from within the `import_makefile_name` makefile
  * See the imports section for more details

## Makefiles

### go.mk

This Makefile was specifically crafted to support the SUDOLESS Golang project and deployment style. It assists in
running, versioning, updating, testing, benchmarking and everything else surrounding Go.

#### Features

* Optimized Go building
* Full support for Go latest module, benchmarking, testing, etc
* Improved Go tooling with easy `make dev-deps` download for developers or CI
* Compilation with `-x` ... `_serviceName, _version, _buildTime, _buildHash`
    * Gives runtime access to the build time variables
* Structured project (`./cmd/`, `./pkg/`) allowing for `make run-helloworld` to build and run `./cmd/helloworld/...`
* Strict security, performance and styling checks
* Docker build (`make docker-build-x` and `make docker-list`) with labels and `.netrc` support
  * Automatically names and tags the images based on the project information
  * Makes use of DOCKER_BUILDKIT
  * Makes use of `.netrc`, a very useful "tool" for simple auth (works well with Go private repositories too)
  * Shares binary BUILD info from the runner using `--build-arg`
* Basic Docker tag and push commands
* Barebone project skeleton setup with `make init`

#### TODO

* Add support for multi-module repos
* Add deployment integration
* Add changelog management
* Add release management
* Add env integration


### container.mk

This Makefile has been created with the SUDOLESS container practices in mind. It assists with building, tagging, pushing
and any other necessary container interactions.

#### Features

* Container tool selection support (`docker` or `podman`)
* Container image listing for current project
* Container building with labels and build args
* Container tag and push commands
* Container machine and host information logging

## Imports

The main `Makefile` uses `THIS_IMPORT_DIR` (`./make`) and `THIS_IMPORT_EXT` (`mk`) to "import" other makefiles. This
system does not make use of the `include` directive, as to not overwrite rules. Instead, when calling a rule, by starting with
an import prefix, followed by `/`, you effectively call `make ./make/import_prefix.mk rule`.

Take the following project tree as example:

```text
.
|- Makefile
|- make/
|   |- go.mk
|   |- container.mk
...
```

When calling `go/help` you are running the `help` rule from within `./make/go.mk`.

### Add

To quickly add a new import, use the `make add/import_name` rule. This will fetch (`curl`) the file from the defined path.
