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
ARG GH_VERSION=2.14.3
RUN curl -fsL -o /tmp/gh.tgz https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_${TARGETARCH}.tar.gz \
    && tar -C /tmp -xzf /tmp/gh.tgz \
    && cp /tmp/gh_${GH_VERSION}_linux_${TARGETARCH}/bin/gh /usr/local/bin \
    && mkdir -p /usr/share/doc/gh \
    && cp /tmp/gh_${GH_VERSION}_linux_${TARGETARCH}/LICENSE /usr/share/doc/gh/LICENSE \
    && rm -rf /tmp/gh_${GH_VERSION}_linux_${TARGETARCH} /tmp/gh.tgz

CMD ["/bin/bash"]
