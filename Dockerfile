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


COPY ./install_securejoin.sh\
    ./install_volepsi.sh\
    /home/FPSI/
RUN chmod +x install_securejoin.sh && \
    ./install_securejoin.sh

RUN chmod +x install_volepsi.sh && \
    ./install_volepsi.sh

COPY ./CMakeLists.txt\
    ./throttle.sh\
    ./README.md\
    ./bench_fmap.sh\
    ./bench_fmap_prefix.sh\
    ./bench_fpsi.sh\
    ./bench_fpsi_prefix.sh\
    /home/FPSI/
COPY ./include/ /home/FPSI/include/
COPY ./src/ /home/FPSI/src/

RUN mkdir -p build && \
    cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j
