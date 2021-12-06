ARG TAG_MINIMAL

FROM k8s.gcr.io/pause:3.2

FROM quay.io/cybozu/ubuntu-minimal:${TAG_MINIMAL}

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        locales \
        tzdata \
        openssl \
        netbase \
        apt-utils \
        apt-transport-https \
        libreadline8 \
        ca-certificates \
        curl \
    && apt-get -y upgrade \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 \
    && echo "Etc/UTC" > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata

COPY --from=0 /pause /usr/local/bin/pause

CMD ["/bin/bash"]
