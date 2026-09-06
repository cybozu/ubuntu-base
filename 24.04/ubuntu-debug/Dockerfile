ARG TAG

FROM ghcr.io/cybozu/ubuntu:${TAG}

RUN apt-get update && apt-get install -y --no-install-recommends \
        apache2-utils \
        bash-completion \
        bind9-dnsutils \
        binutils \
        bsdmainutils \
        conntrack \
        expect \
        file \
        gdb \
        iperf3 \
        iproute2 \
        iputils-ping \
        jq \
        less \
        lsb-release \
        lv \
        moreutils \
        mysql-client \
        net-tools \
        openssh-client \
        perl-modules \
        python3-requests \
        rclone \
        rsync \
        s3cmd \
        smartmontools \
        socat \
        sqlite3 \
        strace \
        sysstat \
        tcpdump \
        telnet \
        traceroute \
        unzip \
        vim \
    && rm -rf /var/lib/apt/lists/*

ARG TARGETARCH
ARG AWSCLI_VERSION=2.36.29
RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64) aws_arch="x86_64"; aws_checksum="cf000f7405c94742e2b3534e5436c8189e48752ccf548477ebaa1b6b8665cdb5" ;; \
        arm64) aws_arch="aarch64"; aws_checksum="d08073ff20ad0b4a5bdcee344b35052caf7aa51383caa66865708eca407125d0" ;; \
        *) echo "unsupported TARGETARCH: ${TARGETARCH}"; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-${aws_arch}-${AWSCLI_VERSION}.zip"; \
    echo "${aws_checksum}  /tmp/awscliv2.zip" | sha256sum -c -; \
    unzip -q /tmp/awscliv2.zip -d /tmp; \
    /tmp/aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update; \
    rm -rf /tmp/aws /tmp/awscliv2.zip

RUN setcap -r /usr/bin/ping

ARG TARGETARCH
ARG GRPCURL_VERSION=1.9.3
RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64) arch="x86_64"; checksum="a926b62a85787ccf73ef8736b3ae554f1242e39d92bb8767a79d6dd23b11d1d5" ;; \
        arm64) arch="arm64"; checksum="b20a00c1cb82ab81ec32696766d4076e99b4cb5ca0823a71767ba64dbea0f263" ;; \
        *) echo "unsupported TARGETARCH: ${TARGETARCH}"; exit 1 ;; \
    esac; \
    base_url="https://github.com/fullstorydev/grpcurl/releases/download/v${GRPCURL_VERSION}"; \
    archive="grpcurl_${GRPCURL_VERSION}_linux_${arch}.tar.gz"; \
    curl -fsSL -o /tmp/grpcurl.tgz "${base_url}/${archive}"; \
    echo "${checksum}  /tmp/grpcurl.tgz" | sha256sum -c -; \
    tar -C /tmp -xzf /tmp/grpcurl.tgz grpcurl LICENSE; \
    install -m 0755 /tmp/grpcurl /usr/local/bin/grpcurl; \
    mkdir -p /usr/local/grpcurl; \
    install -m 0644 /tmp/LICENSE /usr/local/grpcurl/LICENSE; \
    rm -f /tmp/grpcurl /tmp/LICENSE /tmp/grpcurl.tgz

ARG CRANE_VERSION=0.21.9
RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64) crane_arch="x86_64"; checksum="5c16d8ddb971cb1d5e6ed8b1e743da8224414eeba2c2762d8f1a61b2f095699e" ;; \
        arm64) crane_arch="arm64"; checksum="1f4c647b7bb260ab5435661df5b526cf59950ebf95201790db7183ac189cbcbd" ;; \
        *) echo "unsupported TARGETARCH: ${TARGETARCH}"; exit 1 ;; \
    esac; \
    base_url="https://github.com/google/go-containerregistry/releases/download/v${CRANE_VERSION}"; \
    archive="go-containerregistry_Linux_${crane_arch}.tar.gz"; \
    curl -fsSL -o /tmp/crane.tgz "${base_url}/${archive}"; \
    echo "${checksum}  /tmp/crane.tgz" | sha256sum -c -; \
    tar -C /tmp -xzf /tmp/crane.tgz; \
    install -m 0755 /tmp/crane /usr/local/bin/crane; \
    mkdir -p /usr/local/go-containerregistry; \
    install -m 0644 /tmp/LICENSE /usr/local/go-containerregistry/LICENSE; \
    rm -f /tmp/crane /tmp/LICENSE /tmp/crane.tgz

RUN adduser --disabled-password --gecos "" --uid 10000 cybozu

CMD ["/bin/bash"]
