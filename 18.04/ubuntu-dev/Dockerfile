FROM quay.io/cybozu/ubuntu:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        openssh-client \
        jq \
        libreadline-dev \
        libssl-dev \
    && rm -rf /var/lib/apt/lists/*

ARG HUB_VERSION=2.14.2
RUN curl -fsL -o /tmp/hub.tgz https://github.com/github/hub/releases/download/v${HUB_VERSION}/hub-linux-amd64-${HUB_VERSION}.tgz \
    && tar -C /tmp -xzf /tmp/hub.tgz \
    && /tmp/hub-linux-amd64-${HUB_VERSION}/install \
    && mkdir -p /usr/share/doc/hub \
    && cp /tmp/hub-linux-amd64-${HUB_VERSION}/LICENSE /usr/share/doc/hub/LICENSE \
    && rm -rf /tmp/hub-linux-amd64-${HUB_VERSION}

CMD ["/bin/bash"]
