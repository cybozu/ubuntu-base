FROM quay.io/cybozu/ubuntu:latest

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
        openssh-client \
        s3cmd \
        less \
    && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]
