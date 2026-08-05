FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /home/FPSI

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    openssl \
    build-essential \
    cmake \
    git \
    libtool \
    autoconf \
    automake \
    pkg-config \
    iproute2 \
    python3 \
    sudo \
    nasm \
    libssl-dev \
    libgmp-dev \
    wget \
    libfmt-dev \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*


COPY ./build.sh /home/FPSI/
RUN chmod +x build.sh && \
    ./build.sh

COPY ./fmap_bench.sh\
    ./fmap_prefix_bench.sh\
    ./fpsi_bench.sh\
    ./fpsi_prefix_bench.sh\
    ./CMakeLists.txt\
    ./throttle.sh\
    ./README.md\
    /home/FPSI/
COPY ./include/ /home/FPSI/include/
COPY ./src/ /home/FPSI/src/

RUN mkdir -p build && \
    cd build && \
    cmake .. && \
    make -j