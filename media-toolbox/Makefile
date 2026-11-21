# https://github.com/yt-dlp/yt-dlp/releases/tag/2026.10.26
YT_DLP_VERSION := 2026.10.26
# https://github.com/Brainicism/bgutil-ytdlp-pot-provider/releases
BGUTIL_YTDLP_POT_PROVIDER_VERSION := 2.0.2
UID := 1001
GID := 1001
IMAGE := ghcr.io/nlopez/media-toolbox
PLATFORMS ?= linux/amd64
TAG := ${YT_DLP_VERSION}

tag:
	@echo $(TAG)

build:
	@docker buildx build \
		--platform $(PLATFORMS) \
		--build-arg YT_DLP_VERSION=$(YT_DLP_VERSION) \
		--build-arg BGUTIL_YTDLP_POT_PROVIDER_VERSION=$(BGUTIL_YTDLP_POT_PROVIDER_VERSION) \
		--build-arg UID=$(UID) \
		--build-arg GID=$(GID) \
		-t $(IMAGE):$(TAG) \
		-t $(IMAGE):$(TAG)-$(shell git log -1 --pretty=%h) \
		-t $(IMAGE):$(shell git log -1 --pretty=%h) \
		.

build-no-cache:
	@docker buildx build --no-cache \
		--platform $(PLATFORMS) \
		--build-arg YT_DLP_VERSION=$(YT_DLP_VERSION) \
		--build-arg BGUTIL_YTDLP_POT_PROVIDER_VERSION=$(BGUTIL_YTDLP_POT_PROVIDER_VERSION) \
		--build-arg UID=$(UID) \
		--build-arg GID=$(GID) \
		-t $(IMAGE):$(TAG) \
		-t $(IMAGE):$(TAG)-$(shell git log -1 --pretty=%h) \
		-t $(IMAGE):$(shell git log -1 --pretty=%h) \
		.

push: build
	@docker push $(IMAGE):$(TAG)
	@docker push $(IMAGE):$(TAG)-$(shell git log -1 --pretty=%h)
	@docker push $(IMAGE):$(shell git log -1 --pretty=%h)

run: build
	@docker run -it --entrypoint /bin/bash $(IMAGE):$(TAG)
