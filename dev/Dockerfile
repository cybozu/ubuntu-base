FROM quay.io/cybozu/ubuntu:bionic-20180224

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        git \
    && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]
