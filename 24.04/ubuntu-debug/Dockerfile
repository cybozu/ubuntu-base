ARG TAG

FROM ghcr.io/cybozu/ubuntu:${TAG}@sha256:eb1812859faf05ef7ae1320383c6e09356a44d00521d2c6204daddcb507a4231

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
ARG AWSCLI_VERSION=2.34.35
RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64) aws_arch="x86_64"; checksum="16b73e3057451f9889984c75268eb0321ea235459848f00d6cdd0649825ea8a6" ;; \
        arm64) aws_arch="aarch64"; checksum="3b785f3eb4d28efe9882e09633e0e25ac7b450cf57f37ebfc9e4afebc71295ec" ;; \
        *) echo "unsupported TARGETARCH: ${TARGETARCH}"; exit 1 ;; \
    esac; \
    archive="awscli-exe-linux-${aws_arch}-${AWSCLI_VERSION}.zip"; \
    curl -fsSL -o /tmp/awscliv2.zip "https://awscli.amazonaws.com/${archive}"; \
    echo "${checksum}  /tmp/awscliv2.zip" | sha256sum -c -; \
    unzip -q /tmp/awscliv2.zip -d /tmp; \
    /tmp/aws/install; \
    rm -rf /tmp/awscliv2.zip /tmp/aws

RUN setcap -r /usr/bin/ping

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

ARG CRANE_VERSION=0.21.3
RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64) crane_arch="x86_64"; checksum="46dbf12d943efa5673ab654186c5d7c1503580544de0df9325537083436fe5d0" ;; \
        arm64) crane_arch="arm64"; checksum="dabcf2aee76ca72da63b5da5137c910a6852ccff13e35628e8f0a9dd8b73f4f3" ;; \
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
