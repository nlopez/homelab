# syntax=docker/dockerfile:1

# Runner image for the ci-runners scale set (kubernetes/apps/arc-ci-runners):
# the ARC runner plus the tools the jobs moved there expect to find on a
# GitHub-hosted runner. Jobs that need Nix, Docker, or Tailscale stay on
# GitHub-hosted runners.

FROM ghcr.io/actions/actions-runner:2.338.2

USER root

ARG DEBIAN_FRONTEND=noninteractive

# gh comes from GitHub's apt repository; Ubuntu's package lags by years.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl gpg \
 && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      gh \
      python3-yaml \
      shellcheck \
      xz-utils

# The mikefarah yq GitHub-hosted runners ship; Ubuntu's yq is a different tool.
# https://github.com/mikefarah/yq/releases
ARG YQ_VERSION=v4.54.1
ARG YQ_SHA256=8e34fc298390875de416e6a4afcb8cabeceb25d9aa8506c1a2f9353cf702ea5f
RUN curl -fsSL -o /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" \
 && echo "${YQ_SHA256}  /usr/local/bin/yq" | sha256sum -c - \
 && chmod +x /usr/local/bin/yq

USER runner
