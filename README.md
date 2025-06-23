![CI](https://github.com/cybozu/ubuntu-base/workflows/main/badge.svg)

# ubuntu-base

Basic Ubuntu container images for Cybozu products.

## Container Images

### ubuntu-minimal

Simply copies the upstream Ubuntu image without any modifications.

### ubuntu

A standard Ubuntu base image with common utilities and tools.

**Registry URLs:**
- <https://github.com/cybozu/ubuntu-base/pkgs/container/ubuntu>
- <https://quay.io/repository/cybozu/ubuntu>

**Package Documentation:**
- [ubuntu:22.04 Packages](docs/ubuntu-22.04.md)
- [ubuntu:24.04 Packages](docs/ubuntu-24.04.md)

### ubuntu-dev

A development-focused Ubuntu image that includes build tools, compilers, and development libraries.

**Registry URLs:**
- <https://github.com/cybozu/ubuntu-base/pkgs/container/ubuntu-dev>
- <https://quay.io/repository/cybozu/ubuntu-dev>

**Package Documentation:**
- [ubuntu-dev:22.04 Packages](docs/ubuntu-dev-22.04.md)
- [ubuntu-dev:24.04 Packages](docs/ubuntu-dev-24.04.md)

### ubuntu-debug

A comprehensive debugging and troubleshooting Ubuntu image with extensive debugging tools, network utilities, and diagnostic software.

**Registry URLs:**
- <https://github.com/cybozu/ubuntu-base/pkgs/container/ubuntu-debug>
- <https://quay.io/repository/cybozu/ubuntu-debug>

**Package Documentation:**
- [ubuntu-debug:22.04 Packages](docs/ubuntu-debug-22.04.md)
- [ubuntu-debug:24.04 Packages](docs/ubuntu-debug-24.04.md)
