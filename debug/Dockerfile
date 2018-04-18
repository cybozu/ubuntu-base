FROM quay.io/cybozu/ubuntu-dev:18.04

RUN apt-get update && apt-get install -y --no-install-recommends \
        traceroute \
        telnet \
        tcpdump \
        dnsutils \
        net-tools \
        iproute2 \
        jq \
    && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]
