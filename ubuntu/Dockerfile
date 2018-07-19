FROM quay.io/cybozu/ubuntu-minimal:bionic-20180710

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        locales \
        tzdata \
        openssl \
        netbase \
        apt-utils \
        apt-transport-https \
        libreadline7 \
        ca-certificates \
        curl \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 \
    && echo "Etc/UTC" > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata

CMD ["/bin/bash"]
