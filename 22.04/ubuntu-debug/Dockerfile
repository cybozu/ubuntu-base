ARG TAG

FROM --platform=$BUILDPLATFORM ghcr.io/cybozu/golang:1.23-jammy AS builder

WORKDIR /go/src/github.com/fullstorydev/grpcurl
ARG GRPCURL_VERSION=1.9.1
RUN curl -fsSL -o grpcurl.tar.gz "https://github.com/fullstorydev/grpcurl/archive/v${GRPCURL_VERSION}.tar.gz" \
    && tar -x -z --strip-components 1 -f grpcurl.tar.gz \
    && rm -f grpcurl.tar.gz \
    && GOARCH=${TARGETARCH} CGO_ENABLED=0 go build -ldflags "-X \"main.version=${GRPCURL_VERSION}\"" -o /go/bin/grpcurl ./cmd/grpcurl

WORKDIR /go/src/github.com/google/go-containerregistry
ARG CRANE_VERSION=0.20.2
RUN curl -fsSL -o go-containerregistry.tar.gz "https://github.com/google/go-containerregistry/archive/refs/tags/v${CRANE_VERSION}.tar.gz" \
    && tar -x -z --strip-components 1 -f go-containerregistry.tar.gz  \
    && rm -f go-containerregistry.tar.gz \
    && GOARCH=${TARGETARCH} CGO_ENABLED=0 go build -ldflags="-X 'github.com/google/go-containerregistry/cmd/crane/cmd.Version=${CRANE_VERSION}'" -o /go/bin/crane ./cmd/crane

FROM ghcr.io/cybozu/ubuntu:${TAG}

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
COPY --from=builder /go/bin/crane /usr/local/bin
COPY --from=builder /go/src/github.com/fullstorydev/grpcurl/LICENSE /usr/local/grpcurl/LICENSE
COPY --from=builder /go/src/github.com/google/go-containerregistry/LICENSE /usr/local/go-containerregistry/LICENSE

RUN adduser --disabled-password --gecos "" --uid 10000 cybozu

CMD ["/bin/bash"]
