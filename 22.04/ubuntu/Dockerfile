ARG TAG_MINIMAL

FROM registry.k8s.io/pause:3.10@sha256:ee6521f290b2168b6e0935a181d4cff9be1ac3f505666ef0e3c98fae8199917a

FROM ghcr.io/cybozu/ubuntu-minimal:${TAG_MINIMAL}@sha256:81507f913e77df078ce75b14d5d3cd42a314f335f7ced90a2d4c2864f7bbbd4b

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        apt-transport-https \
        apt-utils \
        ca-certificates \
        curl \
        gettext-base \
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
