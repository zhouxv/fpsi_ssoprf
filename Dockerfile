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
    # openssl \
    # pkg-config \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://raw.githubusercontent.com/thombashi/tcconfig/master/scripts/installer.sh | bash


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
