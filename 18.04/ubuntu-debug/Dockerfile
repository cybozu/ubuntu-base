FROM quay.io/cybozu/ubuntu:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
        awscli \
        binutils \
        dnsutils \
        file \
        gdb \
        iproute2 \
        iputils-ping \
        jq \
        less \
        lv \
        mysql-client \
        net-tools \
        openssh-client \
        s3cmd \
        strace \
        sysstat \
        tcpdump \
        telnet \
        traceroute \
        vim \
    && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]
