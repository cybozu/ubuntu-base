FROM quay.io/cybozu/ubuntu:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        libreadline-dev \
        libssl-dev \
    && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]
