ARG TAG
FROM quay.io/cybozu/ubuntu:${TAG}

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        openssh-client \
        jq \
        libreadline-dev \
        libssl-dev \
    && rm -rf /var/lib/apt/lists/*

ARG TARGETARCH
ARG HUB_VERSION=2.14.2
ARG GH_VERSION=2.45.0
RUN curl -fsL -o /tmp/hub.tgz https://github.com/github/hub/releases/download/v${HUB_VERSION}/hub-linux-${TARGETARCH}-${HUB_VERSION}.tgz \
    && tar -C /tmp -xzf /tmp/hub.tgz \
    && /tmp/hub-linux-${TARGETARCH}-${HUB_VERSION}/install \
    && mkdir -p /usr/share/doc/hub \
    && cp /tmp/hub-linux-${TARGETARCH}-${HUB_VERSION}/LICENSE /usr/share/doc/hub/LICENSE \
    && rm -rf /tmp/hub-linux-${TARGETARCH}-${HUB_VERSION} /tmp/hub.tgz \
    && curl -fsL -o /tmp/gh.tgz https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_${TARGETARCH}.tar.gz \
    && tar -C /tmp -xzf /tmp/gh.tgz \
    && cp /tmp/gh_${GH_VERSION}_linux_${TARGETARCH}/bin/gh /usr/local/bin \
    && mkdir -p /usr/share/doc/gh \
    && cp /tmp/gh_${GH_VERSION}_linux_${TARGETARCH}/LICENSE /usr/share/doc/gh/LICENSE \
    && rm -rf /tmp/gh_${GH_VERSION}_linux_${TARGETARCH} /tmp/gh.tgz

CMD ["/bin/bash"]
