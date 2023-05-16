KIND_CLUSTER_NAME ?= kind
VERSION ?= v0.0.4
IMAGE_REPO?= 

REPO_ROOT = $(shell pwd)

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: image
image: ## make image IMAGE_REPO=<image-repo> . Build approver-policy + example plugin image.
	docker build \
	  --load \
	  -t $(IMAGE_REPO)/cert-manager-example-approver-policy-plugin:$(VERSION) \
	  .

.PHONY: image-load
image-load: image ## make image-load IMAGE_REPO=<image-repo> [KIND_CLUSTER_NAME=<name>]. Build and tag an image and load it to the specified kind cluster
	kind load docker-image \
	--name $(KIND_CLUSTER_NAME) \
	$(IMAGE_REPO)/cert-manager-example-approver-policy-plugin:$(VERSION)

.PHONY: deploy
deploy: image-load ## make deploy IMAGE_REPO=<image-repo> [KIND_CLUSTER_NAME=<name>]. Build and load an image, deploy approver policy with the plugin to the specified cluster.
	helm dependency build $(REPO_ROOT)/deploy/charts/example-approver-policy-plugin && \
	helm upgrade --install cert-manager-approver-policy \
	$(REPO_ROOT)/deploy/charts/example-approver-policy-plugin \
	--set cert-manager-approver-policy.image.repository=$(IMAGE_REPO)/cert-manager-example-approver-policy-plugin \
	--set cert-manager-approver-policy.image.tag=$(VERSION) \
	--namespace cert-manager
