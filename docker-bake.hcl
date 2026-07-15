variable "UBUNTU_VERSION" {
  type        = string
  description = "Ubuntu major.minor directory to build from (e.g. 22.04, 24.04)."
  validation {
    condition     = UBUNTU_VERSION != ""
    error_message = "UBUNTU_VERSION must not be empty"
  }
}

variable "TAG_MINIMAL" {
  type        = string
  description = "Upstream ubuntu tag used by ubuntu-minimal base (e.g. jammy-20260514)."
  validation {
    condition     = TAG_MINIMAL != ""
    error_message = "TAG_MINIMAL must not be empty"
  }
}

variable "DIGEST_DOCKERHUB_UBUNTU" {
  type        = string
  description = "Pinned digest for the upstream ubuntu tag in Docker Hub."
  validation {
    condition     = DIGEST_DOCKERHUB_UBUNTU != ""
    error_message = "DIGEST_DOCKERHUB_UBUNTU must not be empty"
  }
}

variable "TAG" {
  type        = string
  description = "Release tag for ubuntu/ubuntu-dev/ubuntu-debug images (e.g. 22.04.20260603)."
  validation {
    condition     = TAG != ""
    error_message = "TAG must not be empty"
  }
}

group "default" {
  targets = ["ubuntu-minimal", "ubuntu", "ubuntu-dev", "ubuntu-debug"]
}

target "ubuntu-minimal" {
  context    = "${UBUNTU_VERSION}/ubuntu-minimal"
  dockerfile = "Dockerfile"
  platforms = ["linux/amd64", "linux/arm64/v8"]
  args = {
    TAG_MINIMAL             = "${TAG_MINIMAL}"
    DIGEST_DOCKERHUB_UBUNTU = "${DIGEST_DOCKERHUB_UBUNTU}"
  }
  tags = ["ghcr.io/cybozu/ubuntu-minimal:${TAG_MINIMAL}"]
}

target "ubuntu" {
  context    = "${UBUNTU_VERSION}/ubuntu"
  dockerfile = "Dockerfile"
  platforms = ["linux/amd64", "linux/arm64/v8"]
  contexts = {
    "ghcr.io/cybozu/ubuntu-minimal:${TAG_MINIMAL}" = "target:ubuntu-minimal"
  }
  args = {
    TAG_MINIMAL = "${TAG_MINIMAL}"
  }
  tags = [
    "ghcr.io/cybozu/ubuntu:${TAG}",
    "ghcr.io/cybozu/ubuntu:${UBUNTU_VERSION}",
  ]
}

target "ubuntu-dev" {
  context    = "${UBUNTU_VERSION}/ubuntu-dev"
  dockerfile = "Dockerfile"
  platforms = ["linux/amd64", "linux/arm64/v8"]
  contexts = {
    "ghcr.io/cybozu/ubuntu:${TAG}" = "target:ubuntu"
  }
  args = {
    TAG = "${TAG}"
  }
  tags = [
    "ghcr.io/cybozu/ubuntu-dev:${TAG}",
    "ghcr.io/cybozu/ubuntu-dev:${UBUNTU_VERSION}",
  ]
}

target "ubuntu-debug" {
  context    = "${UBUNTU_VERSION}/ubuntu-debug"
  dockerfile = "Dockerfile"
  platforms = ["linux/amd64", "linux/arm64/v8"]
  contexts = {
    "ghcr.io/cybozu/ubuntu:${TAG}" = "target:ubuntu"
  }
  args = {
    TAG = "${TAG}"
  }
  tags = [
    "ghcr.io/cybozu/ubuntu-debug:${TAG}",
    "ghcr.io/cybozu/ubuntu-debug:${UBUNTU_VERSION}",
  ]
}
