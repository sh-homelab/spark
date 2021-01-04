SHELL=/bin/bash

SPARK_VERSION ?= 3.0.1
HADOOP_VERSION ?= 3.2

# External packages 
AWS_SDK_VERSION ?= 1.11.762
HADOOP_AWS_VERSION ?= 3.2.1

DOCKERIZE_VERSION ?= v0.6.1
SPARK_UID ?= $(shell id -u ${USER})

IMAGE_NAME = sh-homelab/spark
IMAGE_TAG = $(SPARK_VERSION)-hadoop-$(HADOOP_VERSION)
IMAGE_TAG_ARG = --tag $(IMAGE_NAME):$(IMAGE_TAG)

BUILD_NUMBER ?= 0
BUILD_CREATOR = $(shell git config user.email)
GIT_BRANCH = test
#$(shell git name-rev --name-only HEAD | sed 's/~.*//')
GIT_COMMIT = $(shell git rev-parse HEAD)
GIT_COMMIT_SHORT = $(shell echo $(GIT_COMMIT) | head -c 8)
GIT_DIRTY = $(if $(shell git status -s),true,false)

BUILD_CMD = docker build
IMAGE_CMD = docker image

BUILD_CONTEXT = .
DOCKERFILE = Dockerfile

BUILD_ARGS = \
	--build-arg SPARK_VERSION=$(SPARK_VERSION) \
	--build-arg HADOOP_VERSION=$(HADOOP_VERSION) \
	--build-arg AWS_SDK_VERSION=$(AWS_SDK_VERSION) \
	--build-arg HADOOP_AWS_VERSION=$(HADOOP_AWS_VERSION) \
	--build-arg DOCKERIZE_VERSION=$(DOCKERIZE_VERSION) \
	--build-arg SPARK_UID=$(SPARK_UID) \
	--build-arg IMAGE_TAG=$(IMAGE_TAG) \
	--build-arg GIT_BRANCH=$(GIT_BRANCH) \
	--build-arg GIT_COMMIT=$(GIT_COMMIT) \
	--build-arg GIT_DIRTY=$(GIT_DIRTY) \
	--build-arg BUILD_CREATOR=$(BUILD_CREATOR) \
	--build-arg BUILD_NUMBER=$(BUILD_NUMBER)

.PHONY: pre-build docker-build post-build build tag

build: pre-build docker-build post-build
build-nocache: pre-build docker-build-nocache post-build

pre-build:
	@docker -v
	@git --version
	@echo
	@echo Build: $(IMAGE_NAME):$(IMAGE_TAG)
	@echo

post-build:
	$(IMAGE_CMD) prune --filter 'dangling=true' -f
	$(IMAGE_CMD) ls $(IMAGE_NAME):$(IMAGE_TAG)

docker-build:
	$(BUILD_CMD) $(IMAGE_TAG_ARG) $(BUILD_ARGS) -f $(DOCKERFILE) $(BUILD_CONTEXT)

docker-build-nocache:
	$(BUILD_CMD) --no-cache $(IMAGE_TAG_ARG) $(BUILD_ARGS) -f $(DOCKERFILE) $(BUILD_CONTEXT)

clean:
	$(IMAGE_CMD) rmi -f $(IMAGE_NAME):$(IMAGE_TAG)

show:
	@echo $(IMAGE_TAG)
	@echo $(HADOOP_MAJOR_VERSION)
	@echo $(BUILD_ARGS)
