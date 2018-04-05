FROM quay.io/cybozu/ubuntu:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        git \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

CMD ["/bin/bash"]
