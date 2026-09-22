FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /workspace


# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    autoconf \
    automake \
    libgmp-dev \
    libspdlog-dev \
    libtool \
    libssl-dev \
    libmpfr-dev \
    libfmt-dev \
    nasm \
    python3 \
    python3-pip \
    python3-venv \
    vim \
    git \
    iproute2 \
    net-tools \
    curl \
    jq \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://raw.githubusercontent.com/thombashi/tcconfig/master/scripts/installer.sh | bash

COPY --chmod=755 ./shell_install_dependencies.sh /workspace/shell_install_dependencies.sh
RUN ./shell_install_dependencies.sh

COPY ./CMakeLists.txt \
    ./README.md \
    /workspace/
COPY ./include/ /workspace/include/
COPY ./src/ /workspace/src/

COPY --chmod=755 ./shell_run_bench_fpsi.sh /workspace/shell_run_bench_fpsi.sh
COPY --chmod=755 ./shell_config_network.sh /workspace/shell_config_network.sh

RUN mkdir -p build && \
    cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j
