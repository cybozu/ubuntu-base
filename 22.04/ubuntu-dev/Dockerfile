ARG DIGEST_UBUNTU

FROM ghcr.io/cybozu/ubuntu@${DIGEST_UBUNTU}

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        jq \
        libreadline-dev \
        libssl-dev \
        openssh-client \
    && rm -rf /var/lib/apt/lists/*

ARG TARGETARCH
ARG GH_VERSION=2.89.0
RUN set -eux; \
    archive="gh_${GH_VERSION}_linux_${TARGETARCH}.tar.gz"; \
    base_url="https://github.com/cli/cli/releases/download/v${GH_VERSION}"; \
    case "${TARGETARCH}" in \
        amd64) checksum="d0422caade520530e76c1c558da47daebaa8e1203d6b7ff10ad7d6faba3490d8" ;; \
        arm64) checksum="9e64a623dfc242990aa5d9b3f507111149c4282f66b68eaad1dc79eeb13b9ce5" ;; \
        *) echo "unsupported TARGETARCH: ${TARGETARCH}"; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/gh.tgz "${base_url}/${archive}"; \
    echo "${checksum}  /tmp/gh.tgz" | sha256sum -c -; \
    tar -C /tmp -xzf /tmp/gh.tgz; \
    cp /tmp/gh_${GH_VERSION}_linux_${TARGETARCH}/bin/gh /usr/local/bin; \
    mkdir -p /usr/share/doc/gh; \
    cp /tmp/gh_${GH_VERSION}_linux_${TARGETARCH}/LICENSE /usr/share/doc/gh/LICENSE; \
    rm -rf /tmp/gh_${GH_VERSION}_linux_${TARGETARCH} /tmp/gh.tgz

CMD ["/bin/bash"]
