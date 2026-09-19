FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /workspace

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
    libfmt-dev \
    curl \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*


COPY shell_install_dependencies.sh \
    /workspace/

RUN chmod +x shell_install_dependencies.sh && \
    ./shell_install_dependencies.sh

COPY ./CMakeLists.txt \
    ./README.md \
    ./shell_bench_fpsi_prefix.sh \
    ./shell_config_network.sh \
    /workspace/
COPY ./include/ /workspace/include/
COPY ./src/ /workspace/src/
RUN chmod +x *.sh

RUN mkdir -p build && \
    cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j
