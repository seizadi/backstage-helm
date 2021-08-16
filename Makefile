BACKEND_DOCKERFILE_PATH := $(CURDIR)/packages/backend
FRONTEND_DOCKERFILE_PATH := $(CURDIR)

# configuration for image names
USERNAME       := $(USER)
GIT_COMMIT     := $(shell git describe --dirty=-unsupported --always || echo pre-commit)
IMAGE_VERSION  ?= $(USERNAME)-dev-$(GIT_COMMIT)
IMAGE_REGISTRY ?= soheileizadi

# configuration for server binary and image
BACKEND_SERVER_IMAGE      := $(IMAGE_REGISTRY)/backstage-backend
BACKEND_SERVER_DOCKERFILE := $(BACKEND_DOCKERFILE_PATH)/Dockerfile
FRONTEND_SERVER_IMAGE      := $(IMAGE_REGISTRY)/backstage-frontend
FRONTEND_SERVER_DOCKERFILE := $(FRONTEND_DOCKERFILE_PATH)/Dockerfile

# Placeholder. modify as defined conventions.
DB_VERSION        := 1
SRV_VERSION       := $(shell git describe --tags)
API_VERSION       := v1

packages/backend/dist/bundle.tar.gz:
	yarn build

.PHONY: backend_docker
backend_docker: packages/backend/dist/bundle.tar.gz
	@docker build --build-arg db_version=$(DB_VERSION) --build-arg api_version=$(API_VERSION) --build-arg srv_version=$(SRV_VERSION) -f $(BACKEND_SERVER_DOCKERFILE) -t $(BACKEND_SERVER_IMAGE):$(IMAGE_VERSION) .
	@docker tag $(BACKEND_SERVER_IMAGE):$(IMAGE_VERSION) $(BACKEND_SERVER_IMAGE):latest
	@docker image prune -f --filter label=stage=server-intermediate
	@docker push $(BACKEND_SERVER_IMAGE)

.PHONY: backend_push
backend_push:
	@docker push $(BACKEND_SERVER_IMAGE)

.PHONY: frontend_docker
frontend_docker: packages/backend/dist/bundle.tar.gz
	@docker build --build-arg db_version=$(DB_VERSION) --build-arg api_version=$(API_VERSION) --build-arg srv_version=$(SRV_VERSION) -f $(FRONTEND_SERVER_DOCKERFILE) -t $(FRONTEND_SERVER_IMAGE):$(IMAGE_VERSION) .
	@docker tag $(FRONTEND_SERVER_IMAGE):$(IMAGE_VERSION) $(FRONTEND_SERVER_IMAGE):latest
	@docker image prune -f --filter label=stage=server-intermediate
	@docker push $(FRONTEND_SERVER_IMAGE)

.PHONY: frontend_push
frontend_push:
	@docker push $(FRONTEND_SERVER_IMAGE)

