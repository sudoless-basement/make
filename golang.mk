export PATH := $(abspath bin/):${PATH}
export CGO_ENABLED ?= 0

GO ?= GO111MODULE=on go
GO_VERSION ?= 1.15
GO_TAGS ?= timetzdata

DIR_OUT   := out

FILE_COV  := $(DIR_OUT)/cover.out

BUILD_HASH ?= $(shell git rev-parse --short HEAD 2>/dev/null)
BUILD_VERSION ?= $(shell git describe --tags --exact-match 2>/dev/null || git symbolic-ref -q --short HEAD)
BUILD_TIME ?= $$(date +%s)


all: clean lint spelling check test


.PHONY: run-%
run-%: build-% ## run the specified target
	@$(DIR_OUT)/dist/$*_$$(go env GOOS)_$$(go env GOARCH)

.PHONY: build-%
build-%: ## build a specific cmd/$(TARGET)/... into $(DIR_OUT)/dist/$(TARGET)...
	@echo "building $* version=$(BUILD_VERSION) buildhash=$(BUILD_HASH)"
	@$(GO) build -trimpath -tags "$(GO_TAGS)" \
		-ldflags="-w -s \
			-X main._serviceName=$*           \
			-X main._version=$(BUILD_VERSION) \
			-X main._buildTime=$(BUILD_TIME)  \
			-X main._buildHash=$(BUILD_HASH)" \
		-o $(DIR_OUT)/dist/$*_$$(go env GOOS)_$$(go env GOARCH) \
		./cmd/$*/...

.PHONY: clean
clean: ## remove build time generated files
	rm -rf $(DIR_OUT)/

.PHONY: purge
purge: clean ## remove everything that could cause environment issues
	$(GO) mod tidy
	$(GO) clean -cache
	$(GO) clean -testcache
	$(GO) clean -modcache

$(DIR_OUT):
	@mkdir -p $(DIR_OUT)

.PHONY: test
test: export CGO_ENABLED=1
test: $(DIR_OUT) ## run unit tests
	@gotestsum \
		--junitfile $(FILE_COV).xml \
		--format short -- \
		-race \
		-covermode=atomic -coverpkg=./... -coverprofile=$(FILE_COV).txt \
		./...

.PHONY: test-deps
test-deps: ## run tests with dependencies
	$(GO) test all

.PHONY: bench
bench: ## run benchmarks
	$(GO) test -exclude-dir=vendor -exclude-dir=.cache -bench=. -benchmem -benchtime=10s ./...

.PHONY: cover
cover: ## open coverage file in browser
	$(GO) tool cover -html=$(FILE_COV).txt

.PHONY: mod
mod: ## tidy and verify go modules
	$(GO) mod tidy
	$(GO) mod verify

.PHONY: vendor
vendor: ## tidy, vendor and verify dependencies
	$(GO) mod tidy -v
	$(GO) mod vendor -v
	$(GO) mod verify

.PHONY: updates
updates: ## display outdated direct dependencies
	@$(GO) list -u -m -mod=readonly -json all | go-mod-outdated -direct

.PHONY: lint
lint: ## run golangci linter
	@golangci-lint run -v --timeout 2m --skip-dirs=".cache/|vendor/"  ./...

.PHONY: check
check: ## run cyclic and security checks
	@gocyclo -over 16 -ignore ".cache/|vendor/" .
	@gosec -tests -fmt=json -quiet -exclude-dir=vendor -exclude-dir=.cache ./...

.PHONY: spelling
spelling: ## run misspell check
	@misspell -error .

.PHONY: help
help:
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
