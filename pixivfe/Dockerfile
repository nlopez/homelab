# syntax=docker/dockerfile:1

# pixivfe built from an upstream release tag with patches/ applied. Mirrors
# upstream's build/Dockerfile. Drop a patch once upstream ships the fix, and
# this image once no patches are left.

FROM --platform=$BUILDPLATFORM docker.io/library/golang:1.27.3-alpine3.24 AS builder

# https://gitlab.com/pixivfe/PixivFE/-/tags
ARG PIXIVFE_VERSION=v3.1.0

ARG TARGETOS
ARG TARGETARCH

# Fetch the Go release upstream's go.mod asks for if this image's is older.
ENV GOTOOLCHAIN=auto

RUN apk add --no-cache git

WORKDIR /app

RUN git clone --depth 1 --branch "${PIXIVFE_VERSION}" https://gitlab.com/pixivfe/PixivFE.git .

COPY patches/ /patches/

RUN git apply --verbose /patches/*.patch

RUN --mount=type=cache,target=/go/pkg/mod \
  go mod download

RUN env -u GOOS -u GOARCH go tool templ generate

RUN --mount=type=cache,target=/go/pkg/mod \
  --mount=type=cache,target=/root/.cache/go-build \
  go test ./core/ -run 'TestExtractImageLinks'

RUN --mount=type=cache,target=/go/pkg/mod \
  --mount=type=cache,target=/root/.cache/go-build \
  CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -v -trimpath -buildvcs=true -o pixivfe .

RUN echo "pixivfe:x:10001:10001::/:/" >> /etc/passwd && \
    echo "pixivfe:x:10001:" >> /etc/group

FROM scratch AS release

LABEL org.opencontainers.image.source="https://github.com/nlopez/homelab"
LABEL org.opencontainers.image.description="pixivfe with the homelab repo's patches applied"

COPY --from=builder /app/pixivfe /app/pixivfe
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/group /etc/
COPY --from=builder --chown=10001:10001 /app/data /app/data

WORKDIR /app

EXPOSE 8282

USER pixivfe

ENTRYPOINT ["/app/pixivfe"]
