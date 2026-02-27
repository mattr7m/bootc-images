REGISTRY ?= localhost
BASE_TAG  ?= latest
NIDUS_TAG ?= latest
DEV_TAG   ?= latest

BASE_IMAGE  = $(REGISTRY)/bootc-base:$(BASE_TAG)
NIDUS_IMAGE = $(REGISTRY)/bootc-nidus:$(NIDUS_TAG)
DEV_IMAGE   = $(REGISTRY)/bootc-dev:$(DEV_TAG)

.PHONY: build-base build-nidus build-dev build-all \
        push-base push-nidus push-dev push-all \
        stage-base stage-nidus stage-dev stage-all \
        iso-base iso-nidus iso-dev iso-all \
        lint clean help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

build-base: ## Build the base image
	podman build -t $(BASE_IMAGE) images/base/

build-nidus: build-base ## Build the nidus image (builds base first)
	podman build \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		-t $(NIDUS_IMAGE) \
		images/nidus/

build-dev: build-base ## Build the dev image (builds base first)
	podman build \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		-t $(DEV_IMAGE) \
		images/dev/

build-all: build-nidus build-dev ## Build all images

HADOLINT = podman run --rm -i ghcr.io/hadolint/hadolint hadolint --ignore DL3041 --ignore DL3059 -

lint: ## Lint all Containerfiles
	$(HADOLINT) < images/base/Containerfile
	$(HADOLINT) < images/nidus/Containerfile
	$(HADOLINT) < images/dev/Containerfile

clean: ## Remove built images
	-podman rmi $(BASE_IMAGE) $(NIDUS_IMAGE) $(DEV_IMAGE) 2>/dev/null

push-base: ## Push the base image to REGISTRY
	podman push $(BASE_IMAGE)

push-nidus: ## Push the nidus image to REGISTRY
	podman push $(NIDUS_IMAGE)

push-dev: ## Push the dev image to REGISTRY
	podman push $(DEV_IMAGE)

push-all: push-base push-nidus push-dev ## Push all images to REGISTRY

stage-base: ## Copy base image to root's podman storage for ISO builds
	podman save $(BASE_IMAGE) | sudo podman load

stage-nidus: ## Copy nidus image to root's podman storage for ISO builds
	podman save $(NIDUS_IMAGE) | sudo podman load

stage-dev: ## Copy dev image to root's podman storage for ISO builds
	podman save $(DEV_IMAGE) | sudo podman load

stage-all: stage-base stage-nidus stage-dev ## Copy all images to root's podman storage

iso-base: stage-base ## Build Anaconda ISO for base
	sudo scripts/build-iso.sh base

iso-nidus: stage-nidus ## Build Anaconda ISO for nidus
	sudo scripts/build-iso.sh nidus

iso-dev: stage-dev ## Build Anaconda ISO for dev
	sudo scripts/build-iso.sh dev

iso-all: stage-all ## Build Anaconda ISOs for all images
	sudo scripts/build-iso.sh all
