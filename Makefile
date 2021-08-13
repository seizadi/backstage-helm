DOCKERFILE_PATH := $(CURDIR)/packages/backend

# configuration for image names
USERNAME       := $(USER)
GIT_COMMIT     := $(shell git describe --dirty=-unsupported --always || echo pre-commit)
IMAGE_VERSION  ?= $(USERNAME)-dev-$(GIT_COMMIT)
IMAGE_REGISTRY ?= soheileizadi

# configuration for server binary and image
SERVER_IMAGE      := $(IMAGE_REGISTRY)/backstage-backend
SERVER_DOCKERFILE := $(DOCKERFILE_PATH)/Dockerfile

# Placeholder. modify as defined conventions.
DB_VERSION        := 1
SRV_VERSION       := $(shell git describe --tags)
API_VERSION       := v1

packages/backend/dist/bundle.tar.gz:
	yarn build

.PHONY: docker
docker: packages/backend/dist/bundle.tar.gz
	@docker build --build-arg db_version=$(DB_VERSION) --build-arg api_version=$(API_VERSION) --build-arg srv_version=$(SRV_VERSION) -f $(SERVER_DOCKERFILE) -t $(SERVER_IMAGE):$(IMAGE_VERSION) .
	@docker tag $(SERVER_IMAGE):$(IMAGE_VERSION) $(SERVER_IMAGE):latest
	@docker image prune -f --filter label=stage=server-intermediate
	@docker push $(SERVER_IMAGE)

.PHONY: push
push:
	@docker push $(SERVER_IMAGE)

