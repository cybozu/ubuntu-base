ARG TAG
FROM --platform=$BUILDPLATFORM quay.io/cybozu/golang:1.21-jammy AS builder

WORKDIR /go/src/github.com/fullstorydev/grpcurl
ARG GRPCURL_VERSION=1.8.9
RUN curl -fsSL -o grpcurl.tar.gz "https://github.com/fullstorydev/grpcurl/archive/v${GRPCURL_VERSION}.tar.gz" \
    && tar -x -z --strip-components 1 -f grpcurl.tar.gz \
    && rm -f grpcurl.tar.gz \
    && GOARCH=${TARGETARCH} CGO_ENABLED=0 go build -ldflags "-X \"main.version=${GRPCURL_VERSION}\"" -o /go/bin/grpcurl ./cmd/grpcurl

FROM quay.io/cybozu/ubuntu:${TAG}

RUN apt-get update && apt-get install -y --no-install-recommends \
        apache2-utils \
        awscli \
        bash-completion \
        bind9-dnsutils \
        binutils \
        bsdmainutils \
        expect \
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
        perl-modules \
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
        vim \
    && rm -rf /var/lib/apt/lists/*

RUN setcap -r /usr/bin/ping

COPY --from=builder /go/bin/grpcurl /usr/local/bin
COPY --from=builder /go/src/github.com/fullstorydev/grpcurl/LICENSE /usr/local/grpcurl/LICENSE

RUN adduser --disabled-password --gecos "" --uid 10000 cybozu
USER cybozu

CMD ["/bin/bash"]
