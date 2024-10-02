ARG TAG_MINIMAL

FROM registry.k8s.io/pause:3.10

FROM ghcr.io/cybozu/ubuntu-minimal:${TAG_MINIMAL}

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        apt-transport-https \
        apt-utils \
        ca-certificates \
        curl \
        libreadline8 \
        locales \
        netbase \
        openssl \
        tzdata \
    && apt-get -y upgrade \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 \
    && echo "Etc/UTC" > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata

COPY --from=0 /pause /usr/local/bin/pause

CMD ["/bin/bash"]
