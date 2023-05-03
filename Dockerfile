FROM golang:1.19.7-buster AS lotus-build

# Lotus repository
ARG REPOSITORY="consensus-shipyard/lotus"
# Git branch of the lotus repository
ARG BRANCH="v0.2.0"
# Filecoin network. Valid values: lotus, calibnet, hyperspace
ARG NETWORK="spacenet"

# Build FFI from source
ENV RUSTFLAGS="-C target-cpu=native -g"
ENV FFI_BUILD_FROM_SOURCE=1

# Install packages required by lotus
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        mesa-opencl-icd \
        ocl-icd-opencl-dev \
        gcc \
        git \
        bzr \
        jq \
        pkg-config \
        curl \
        clang \
        build-essential \
        hwloc \
        libhwloc-dev \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install lotus
RUN git clone https://github.com/${REPOSITORY}.git --depth 1 --branch $BRANCH && \
    cd lotus && \
    make clean deps && \
    make $NETWORK lotus-gateway && \
    install -C ./eudico /usr/local/bin/eudico && \
    install -C ./lotus-seed /usr/local/bin/lotus-seed && \
    install -C ./lotus-keygen /usr/local/bin/lotus-keygen && \
    install -C ./lotus-shed /usr/local/bin/lotus-shed && \
    install -C ./lotus-gateway /usr/local/bin/lotus-gateway



#FROM ubuntu:20.04 AS lotus-base
#
## Copy software dependencies
#COPY --from=lotus-build \
#    /usr/lib/*/libhwloc.so.5 \
#    /usr/lib/*/libnuma.so.1 \
#    /usr/lib/*/libltdl.so.7 \
#    /lib/
#
## Copy OpenCL
#COPY --from=lotus-build \
#    /usr/lib/*/libOpenCL.so.1.0.0 \
#    /lib/libOpenCL.so.1
#
## Copy SSL certificates
#COPY --from=lotus-build \
#    /etc/ssl/certs \
#    /etc/ssl/certs
#
## Copy lotus binaries
#COPY --from=lotus-build \
#    /usr/local/bin/eudico \
#    /usr/local/bin/lotus-seed \
#    /usr/local/bin/lotus-keygen \
#    /usr/local/bin/lotus-gateway \
#    /usr/local/bin/
#
## Copy eudico configs
#COPY --from=lotus-build \
#    /lotus/eudico-core/genesis/genesis-test.json \
#    /lotus/eudico-core/genesis/genesis.json \
#    /lotus/scripts/ipc/src/wallet.key \
#    /etc/lotus/docker/
#
#
#FROM lotus-base AS lotus-runtime
#
## Install JQ
#RUN apt-get update && \
#    apt-get install -y --no-install-recommends \
#        jq  \
#        curl \
#        nano \
#        tmux && \
#    apt-get clean && \
#    rm -rf /var/lib/apt/lists/*
#
## Copy lotus version
#COPY LOTUS_VERSION /VERSION
#
## Copy lotus config
#COPY config/config.toml /home/lotus_user/config.toml
#
## Copy the healthcheck script
#COPY scripts/healthcheck /bin/
#
## Copy config scripts
#COPY scripts/bash-config \
#    scripts/configure \
#    scripts/run \
#    scripts/launch \
#    scripts/ensure \
#    scripts/root-single-validator \
#    scripts/subnet-daemon \
#    /etc/lotus/docker/
#
## Create lotus user
#RUN adduser --uid 2000 --gecos "" --disabled-password --quiet lotus_user
#
## Add permissions for the lotus_user
#RUN chown lotus_user /home/lotus_user
#
#USER lotus_user
#
#EXPOSE 1234/tcp
#
#EXPOSE 1235/tcp
#
#ENTRYPOINT ["/etc/lotus/docker/run"]
#
