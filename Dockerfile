FROM golang:1.25-bookworm AS lotus-build

# Lotus repository
ARG REPOSITORY="filecoin-project/lotus"
# Git branch of the lotus repository
ARG BRANCH="master"
# Filecoin network. Valid values: lotus(mainnet), calibnet
ARG NETWORK="lotus"
# Repo folder name
ARG FOLDER_NAME="lotus"


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
RUN git clone https://github.com/${REPOSITORY}.git --depth 1 --branch $BRANCH $FOLDER_NAME && \
    cd $FOLDER_NAME && \
    make clean deps && \
    if [ "$NETWORK" = "calibnet" ]; then \
    make calibnet-lotus-gateway; \
    else \
    make lotus-gateway; \
    fi && \
    make ${NETWORK} lotus-shed && \
    install -C ./lotus-gateway /usr/local/bin/lotus-gateway; \
    install -C ./lotus /usr/local/bin/lotus && \
    install -C ./lotus-shed /usr/local/bin/lotus-shed


FROM debian:bookworm-slim AS lotus-runtime

COPY --from=lotus-build \
    /usr/local/bin/lotus \
    /usr/local/bin/lotus-gateway \
    /usr/local/bin/lotus-shed \
    /usr/local/bin/

# Install runtime apt dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libhwloc15 \
        ocl-icd-libopencl1 \
        libudev1 \
        libcap2 \
        libgcc-s1 \
        ca-certificates \
        jq \
        curl && \
    rm -rf /var/lib/apt/lists/*

# Copy lotus version
COPY LOTUS_VERSION /VERSION

# Copy lotus config
COPY config/config.toml /home/lotus_user/config.toml

# Copy the healthcheck script
COPY scripts/healthcheck /bin/

# Copy config scripts
COPY scripts/bash-config \
    scripts/configure \
    scripts/run \
    scripts/launch \
    /etc/lotus/docker/

# Create lotus group
RUN addgroup --gid 2000 lotus

# Create lotus user
RUN adduser --gid 2000 --uid 2000 --gecos "" --disabled-password --quiet lotus_user

# Add permissions for the lotus_user
RUN chown -R 2000:2000 /home/lotus_user

# # Add permissions for the group lotus
# RUN chmod 664 /home/lotus_user
#
# # Add permissions for the group lotus
# RUN chmod g+s /home/lotus_user

USER lotus_user

EXPOSE 1234/tcp

EXPOSE 1235/tcp

ENTRYPOINT ["/etc/lotus/docker/run"]
