variable "REGISTRY" {
  default = "ghcr.io/cybozu"
}

variable "TAG_MINIMAL" {
  default = ""
}

variable "TAG" {
  default = ""
}

group "default" {
  targets = ["ubuntu-dev", "ubuntu-debug"]
}

target "ubuntu-minimal" {
  context    = "ubuntu-minimal"
  dockerfile = "Dockerfile"
  args = {
    TAG_MINIMAL = "${TAG_MINIMAL}"
  }
  tags = [
    "${REGISTRY}/ubuntu-minimal:${TAG_MINIMAL}"
  ]
}

target "ubuntu" {
  context    = "ubuntu"
  dockerfile = "Dockerfile"
  contexts = {
    ubuntu_minimal = "target:ubuntu-minimal"
  }
  args = {
    TAG_MINIMAL          = "${TAG_MINIMAL}"
    UBUNTU_MINIMAL_IMAGE = "ubuntu_minimal"
  }
  tags = [
    "${REGISTRY}/ubuntu:${TAG_MINIMAL}"
  ]
}

target "ubuntu-dev" {
  context    = "ubuntu-dev"
  dockerfile = "Dockerfile"
  contexts = {
    ubuntu = "target:ubuntu"
  }
  args = {
    TAG          = "${TAG}"
    UBUNTU_IMAGE = "ubuntu"
  }
  tags = [
    "${REGISTRY}/ubuntu-dev:${TAG}"
  ]
}

target "ubuntu-debug" {
  context    = "ubuntu-debug"
  dockerfile = "Dockerfile"
  contexts = {
    ubuntu = "target:ubuntu"
  }
  args = {
    TAG          = "${TAG}"
    UBUNTU_IMAGE = "ubuntu"
  }
  tags = [
    "${REGISTRY}/ubuntu-debug:${TAG}"
  ]
}