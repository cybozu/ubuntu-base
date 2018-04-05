FROM quay.io/cybozu/ubuntu-minimal:bionic-20180224

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        locales \
        tzdata \
        procps \
        netbase \
        apt-utils \
        apt-transport-https \
        curl \
    && rm -rf /var/lib/apt/lists/* \

RUN locale-gen en_US.UTF-8 \
    && update-locale LNAG=en_US.UTF-8 \
    && echo "UTC" > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata

CMD ["/bin/bash"]
