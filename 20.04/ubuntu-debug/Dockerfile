ARG TAG

FROM --platform=$BUILDPLATFORM quay.io/cybozu/golang:1.21-focal AS builder

WORKDIR /go/src/github.com/fullstorydev/grpcurl
ARG GRPCURL_VERSION=1.8.9
ARG TARGETARCH
RUN curl -fsSL -o grpcurl.tar.gz "https://github.com/fullstorydev/grpcurl/archive/v${GRPCURL_VERSION}.tar.gz" \
    && tar -x -z --strip-components 1 -f grpcurl.tar.gz \
    && rm -f grpcurl.tar.gz \
    && GOARCH=${TARGETARCH} CGO_ENABLED=0 go build -ldflags "-X \"main.version=${GRPCURL_VERSION}\"" -o /go/bin/grpcurl ./cmd/grpcurl

FROM quay.io/cybozu/ubuntu:${TAG}

RUN apt-get update && apt-get install -y --no-install-recommends \
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
        s3cmd \
        sqlite3 \
        strace \
        sysstat \
        tcpdump \
        telnet \
        traceroute \
        vim \
        apache2-utils \
        perl-modules \
    && rm -rf /var/lib/apt/lists/*

RUN setcap -r /usr/bin/ping

COPY --from=builder /go/bin/grpcurl /usr/local/bin
COPY --from=builder /go/src/github.com/fullstorydev/grpcurl/LICENSE /usr/local/grpcurl/LICENSE

CMD ["/bin/bash"]
