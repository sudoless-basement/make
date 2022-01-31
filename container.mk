#      @ SUDOLESS SRL <contact@sudoless.org>
#      This Source Code Form is subject to the
#      terms of the Mozilla Public License, v.
#      2.0. If a copy of the MPL was not
#      distributed with this file, You can
#      obtain one at
#      http://mozilla.org/MPL/2.0/.


THIS_MAKEFILE_VERSION = v0.0.2
THIS_MAKEFILE_UPDATE = master
THIS_MAKEFILE := $(lastword $(MAKEFILE_LIST))
THIS_MAKEFILE_URL := https://raw.githubusercontent.com/sudoless/make/$(THIS_MAKEFILE_UPDATE)/container.mk


# CONTAINER
CONTAINER_TOOL ?= docker
CONTAINER_DIR ?= ./deployment/$*
CONTAINER_FILE_NAME ?= Containerfile
CONTAINER_FILE ?= $(CONTAINER_DIR)/$(CONTAINER_FILE_NAME)
CONTAINER_USER ?= $$(whoami)
CONTAINER_BUILD_FLAGS ?=

CONTAINER_CONTEXT ?= .

CONTAINER_IMAGE ?= $(CONTAINER_USER)/$(PROJECT_NAME)/$*
CONTAINER_TAG ?= $(BUILD_VERSION)
CONTAINER_ARTIFACT ?= $(CONTAINER_IMAGE):$(CONTAINER_TAG)

CONTAINER_TARGET_IMAGE ?= $(CONTAINER_IMAGE)
CONTAINER_TARGET_TAG ?= $(CONTAINER_TAG)
CONTAINER_TARGET_ARTIFACT ?= $(CONTAINER_TARGET_IMAGE):$(CONTAINER_TARGET_TAG)


.PHONY: list
list: ## list container images for the current project
	@printf "$(FMT_PRF) listing images for $(FMT_INFO)$(PROJECT_NAME)$(FMT_END) project\n"
	@$(CONTAINER_TOOL) images -f label=project=$(PROJECT_NAME)

.PHONY: build/%
build/%: ## build container image
	@printf "$(FMT_PRFX) building with $(CONTAINER_TOOL) $(FMT_INFO)$$($(CONTAINER_TOOL) version -f 'server: {{.Server.Version}}, client: {{.Client.Version}}')$(FMT_END)\n"
	@printf "$(FMT_PRFX) build machine $(FMT_INFO)$$(whoami)@$$(hostname)$(FMT_END)\n"
	@printf "$(FMT_PRFX) build version $(FMT_INFO)$(BUILD_VERSION)$(FMT_END)\n"
	@printf "$(FMT_PRFX) build context $(FMT_INFO)$(CONTAINER_CONTEXT)$(FMT_END)\n"
	@printf "$(FMT_PRFX) $(CONTAINER_TOOL) on host $(FMT_WARN)$(DOCKER_HOST)$(FMT_END)\n"
	@printf "$(FMT_PRFX) $(CONTAINER_TOOL) file $(FMT_INFO)$(CONTAINER_FILE)$(FMT_END)\n"
	@printf "$(FMT_PRFX) $(CONTAINER_TOOL) artifact output $(FMT_INFO)$(CONTAINER_ARTIFACT)$(FMT_END)\n"
	@DOCKER_BUILDKIT=1 $(CONTAINER_TOOL) build $(CONTAINER_BUILD_FLAGS) \
		--build-arg APP_NAME=$* \
		--build-arg BUILD_VERSION=$(BUILD_VERSION) \
		--build-arg BUILD_HASH=$(BUILD_HASH) \
		-f $(CONTAINER_FILE) -t $(CONTAINER_ARTIFACT) \
		--label "project=$(PROJECT_NAME)" \
		--label "app=$*" \
		--label "build_hash=$(BUILD_HASH)" \
		--label "build_time=$(BUILD_TIME)" \
		--label "build_machine=$$(whoami)@$$(hostname)" $(CONTAINER_CONTEXT)
	@printf "$(FMT_PRFX) $(CONTAINER_TOOL) artifact output $(FMT_INFO)$(CONTAINER_ARTIFACT)$(FMT_END)\n"
	@printf "$(FMT_PRFX) run $(FMT_INFO)$(CONTAINER_TOOL) tag $(CONTAINER_ARTIFACT) ...$(FMT_END) to change name\n"

.PHONY: tag/%
tag/%: ## tag container image
	@printf "$(FMT_PRFX) tagging $(FMT_INFO)$(CONTAINER_ARTIFACT)$(FMT_END)\n"
	@printf "$(FMT_PRFX) as      $(FMT_INFO)$(CONTAINER_TARGET_ARTIFACT)$(FMT_END)\n"
	@$(CONTAINER_TOOL) tag $(CONTAINER_ARTIFACT) $(CONTAINER_TARGET_ARTIFACT)

.PHONY: push/%
push/%: tag/% ## tag and push container image
	@printf "$(FMT_PRFX) pushing $(FMT_INFO)$(CONTAINER_TARGET_ARTIFACT)$(FMT_END)\n"
	@$(CONTAINER_TOOL) push $(CONTAINER_TARGET_ARTIFACT)


# INTERNAL

.PHONY: mk-update
mk-update: ## update this Makefile, use THIS_MAKEFILE_UPDATE=... to specify version
	@printf "$(FMT_PRFX) updating this makefile from $(FMT_INFO)$(THIS_MAKEFILE_VERSION)$(FMT_END) to $(FMT_INFO)$(THIS_MAKEFILE_UPDATE)$(FMT_END)\n"
	@curl -s $(THIS_MAKEFILE_URL) > $(THIS_MAKEFILE).new
	@awk '/^#### CUSTOM/,0' $(THIS_MAKEFILE) | tail -n +2 >> $(THIS_MAKEFILE).new
	@mv -f $(THIS_MAKEFILE).new $(THIS_MAKEFILE)

.PHONY: help
help:
	@grep -h -E '^[a-zA-Z/_-]+%?:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m$(THIS_IMPORT_PREFIX)%-30s\033[0m %s\n", $$1, $$2}'


#### CUSTOM # Anything under the CUSTOM line is migrated by the mk-update command to the new Makefile version
