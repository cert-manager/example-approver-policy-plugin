KIND_CLUSTER_NAME ?= kind
VERSION ?= v0.0.4
IMAGE_REPO?= 

REPO_ROOT = $(shell pwd)

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: image
image:
	docker buildx build \
	  --platform linux/amd64 \
	  --load \
	  -t $(IMAGE_REPO)/cert-manager-example-approver-policy-plugin:$(VERSION) \
	  .

.PHONY: image-load
image-load: image
	kind load docker-image \
	--name $(KIND_CLUSTER_NAME) \
	$(IMAGE_REPO)/cert-manager-example-approver-policy-plugin:$(VERSION)

.PHONY: deploy
deploy: image-load
	helm dependency build $(REPO_ROOT)/deploy/charts/example-approver-policy-plugin && \
	helm upgrade --install cert-manager-approver-policy \
	$(REPO_ROOT)/deploy/charts/example-approver-policy-plugin \
	--set cert-manager-approver-policy.image.repository=$(IMAGE_REPO)/cert-manager-example-approver-policy-plugin \
	--set cert-manager-approver-policy.image.tag=$(VERSION) \
	--namespace cert-manager
