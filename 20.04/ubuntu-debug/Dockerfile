FROM quay.io/cybozu/ubuntu:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
        traceroute \
        telnet \
        tcpdump \
        bind9-dnsutils \
        net-tools \
        iproute2 \
        jq \
        iputils-ping \
        strace \
        gdb \
        vim \
        openssh-client \
        s3cmd \
        mysql-client \
        less \
    && rm -rf /var/lib/apt/lists/*

RUN setcap -r /usr/bin/ping

CMD ["/bin/bash"]
