ARG TAG

FROM ghcr.io/cybozu/ubuntu:${TAG}

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        jq \
        libreadline-dev \
        libssl-dev \
        openssh-client \
    && rm -rf /var/lib/apt/lists/*

ARG TARGETARCH
ARG GH_VERSION=2.98.0

RUN set -eux; \
    archive="gh_${GH_VERSION}_linux_${TARGETARCH}.tar.gz"; \
    base_url="https://github.com/cli/cli/releases/download/v${GH_VERSION}"; \
    case "${TARGETARCH}" in \
        amd64) checksum="3b8ac6b30336802fc1a858d7c084e11cdf24ac1a761ca90b68022d7d729208de" ;; \
        arm64) checksum="cf689084f3a3618f7eae4a2420d335d74626d65f5e594b9828d125d69f800d86" ;; \
        *) echo "unsupported TARGETARCH: ${TARGETARCH}"; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/gh.tgz "${base_url}/${archive}"; \
    echo "${checksum}  /tmp/gh.tgz" | sha256sum -c -; \
    tar -C /tmp -xzf /tmp/gh.tgz; \
    cp /tmp/gh_${GH_VERSION}_linux_${TARGETARCH}/bin/gh /usr/local/bin; \
    mkdir -p /usr/share/doc/gh; \
    cp /tmp/gh_${GH_VERSION}_linux_${TARGETARCH}/LICENSE /usr/share/doc/gh/LICENSE; \
    rm -rf /tmp/gh_${GH_VERSION}_linux_${TARGETARCH} /tmp/gh.tgz
# Disable gh telemetry: https://cli.github.com/telemetry
ENV GH_TELEMETRY=false
ENV DO_NOT_TRACK=true

CMD ["/bin/bash"]
