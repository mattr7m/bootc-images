REGISTRY ?= localhost
BASE_TAG  ?= latest
NIDUS_TAG ?= latest

BASE_IMAGE  = $(REGISTRY)/bootc-base:$(BASE_TAG)
NIDUS_IMAGE = $(REGISTRY)/bootc-nidus:$(NIDUS_TAG)

.PHONY: build-base build-nidus build-all lint clean push-base push-nidus push-all help

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

build-all: build-nidus ## Build all images

lint: ## Lint all Containerfiles
	podman run --rm -i ghcr.io/hadolint/hadolint < images/base/Containerfile
	podman run --rm -i ghcr.io/hadolint/hadolint < images/nidus/Containerfile

clean: ## Remove built images
	-podman rmi $(BASE_IMAGE) $(NIDUS_IMAGE) 2>/dev/null

push-base: ## Push the base image to REGISTRY
	podman push $(BASE_IMAGE)

push-nidus: ## Push the nidus image to REGISTRY
	podman push $(NIDUS_IMAGE)

push-all: push-base push-nidus ## Push all images to REGISTRY
