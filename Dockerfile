FROM golang:1.18.8-alpine AS build-stage

# Repository containing lotus code
ARG REPOSITORY="filecoin-project/lotus"
# Branch from which to build (main, ntwk/hyperspace, etc.)
ARG BRANCH
# Filecoin network to build binaries for (use 'lotus' for mainnet)
ARG NETWORK

# Basic dependencies
RUN apk add --no-cache git jq curl bash wget

# Recommended tweaks (not sure if valueable)
ENV CGO_CFLAGS="-D__BLST_PORTABLE__"
ENV RUSTFLAGS="-C target-cpu=native -g"
ENV FFI_BUILD_FROM_SOURCE=1
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Download lotus
RUN git clone https://github.com/${REPOSITORY}.git --depth 1 --branch ${BRANCH} && \
    cd lotus && \
    git submodule update --init --recursive

# Install lotus dependencies
RUN apk add --no-cache build-base gcc hwloc hwloc-dev opencl opencl-dev libunwind libunwind-dev linux-headers coreutils

# Build lotus binaries
RUN cd lotus && \
    make clean && \
    make ${NETWORK} lotus-shed lotus-gateway && \
    install -C ./lotus /usr/local/bin/lotus && \
    install -C ./lotus-gateway /usr/local/bin/lotus-gateway && \
    install -C ./lotus-shed /usr/local/bin/lotus-shed



FROM alpine:latest

# Copy SSL certificates
COPY --from=build-stage /etc/ssl/certs /etc/ssl/certs

# Copy lotus dependencies
COPY --from=build-stage /lib/libudev.so.1 /lib/
COPY --from=build-stage /usr/lib/libhwloc.so.15 \
                        /usr/lib/libOpenCL.so.1 \
                        /usr/lib/libunwind.so.8 \
                        /usr/lib/libgcc_s.so.1 \
                        /usr/lib/liblzma.so.5 \
                        /usr/lib/libxml2.so.2 \
                        /usr/lib/

# Copy lotus binaries
COPY --from=build-stage /usr/local/bin/lotus \
                        /usr/local/bin/lotus-gateway \
                        /usr/local/bin/lotus-shed \
                        /usr/local/bin/

# Copy lotus config
COPY config/config.toml /home/lotus_user/config.toml

# Copy the healthcheck script
COPY scripts/healthcheck /bin/
# Copy config scripts
COPY scripts/bash-config \
     scripts/configure \
     scripts/run \
     scripts/launch \
     scripts/ensure \
     /etc/lotus/docker/

# Create service user
RUN adduser -u 2000 -g "" -D lotus_user

# Install tooling dependencies
RUN apk add --no-cache curl nano jq bash

USER lotus_user

EXPOSE 1234/tcp

EXPOSE 1235/tcp

ENTRYPOINT ["/etc/lotus/docker/run"]