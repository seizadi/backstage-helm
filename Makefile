DOCKERFILE_PATH := $(CURDIR)/packages/backend

# configuration for image names
USERNAME       := $(shell echo $(USER) | tr A-Z a-z)
GIT_COMMIT     := $(shell git describe --dirty=-unsupported --always || echo pre-commit)
IMAGE_VERSION  ?= $(USERNAME)-dev-$(GIT_COMMIT)
IMAGE_REGISTRY ?= soheileizadi

# configuration for server binary and image
SERVER_IMAGE      := $(IMAGE_REGISTRY)/backstage-backend
FRONTEND_IMAGE    := $(IMAGE_REGISTRY)/backstage-frontend
SERVER_DOCKERFILE := $(DOCKERFILE_PATH)/Dockerfile

# Placeholder. modify as defined conventions.
DB_VERSION        := 1
SRV_VERSION       := $(shell git describe --tags)
API_VERSION       := v1

.PHONY: docker
docker: frontend backend

.PHONY: frontend
frontend:
	cp ./front.dockerignore ./.dockerignore
	yarn install
	yarn tsc
	yarn build
	@docker build -t backstage-frontend -f Dockerfile.hostbuild .
	@docker tag docker.io/library/backstage-frontend:latest $(FRONTEND_IMAGE):$(IMAGE_VERSION)
	@docker tag $(FRONTEND_IMAGE):$(IMAGE_VERSION) $(FRONTEND_IMAGE):latest

.PHONY: backend
backend:
	cp ./back.dockerignore ./.dockerignore
	yarn install
	yarn tsc
	yarn build
	yarn build-image
	@docker tag docker.io/library/backstage:latest $(SERVER_IMAGE):$(IMAGE_VERSION)
	@docker tag $(SERVER_IMAGE):$(IMAGE_VERSION) $(SERVER_IMAGE):latest

packages/backend/dist/bundle.tar.gz:
	yarn build

.PHONY: push
push:
	@docker push $(FRONTEND_IMAGE)
	@docker push $(SERVER_IMAGE)

