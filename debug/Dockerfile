FROM quay.io/cybozu/ubuntu:18.04

RUN apt-get update && apt-get install -y --no-install-recommends \
        traceroute \
        telnet \
        tcpdump \
        dnsutils \
        net-tools \
        iproute2 \
        jq \
        iputils-ping \
        strace \
        gdb \
        vim \
    && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]
