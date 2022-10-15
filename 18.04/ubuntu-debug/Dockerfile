FROM --platform=$BUILDPLATFORM quay.io/cybozu/golang:1.18-focal AS builder

WORKDIR /go/src/github.com/fullstorydev/grpcurl
ARG GRPCURL_VERSION=1.8.7
ARG TARGETARCH
RUN curl -fsSL -o grpcurl.tar.gz "https://github.com/fullstorydev/grpcurl/archive/v${GRPCURL_VERSION}.tar.gz" \
    && tar -x -z --strip-components 1 -f grpcurl.tar.gz \
    && rm -f grpcurl.tar.gz \
    && GOARCH=${TARGETARCH} CGO_ENABLED=0 go build -ldflags "-X \"main.version=${GRPCURL_VERSION}\"" -o /go/bin/grpcurl ./cmd/grpcurl

FROM quay.io/cybozu/ubuntu:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
        awscli \
        binutils \
        dnsutils \
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
        strace \
        sysstat \
        tcpdump \
        telnet \
        traceroute \
        vim \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /go/bin/grpcurl /usr/local/bin
COPY --from=builder /go/src/github.com/fullstorydev/grpcurl/LICENSE /usr/local/grpcurl/LICENSE

CMD ["/bin/bash"]
