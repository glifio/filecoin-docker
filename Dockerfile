# build container stage
FROM golang:1.17.9-buster AS build-env

# branch or tag of the lotus version to build
ARG BRANCH
ARG NETWORK

RUN echo "Building lotus from branch $BRANCH in network $NETWORK"

RUN apt-get update -y && \
    apt-get install sudo cron git mesa-opencl-icd gcc bzr jq pkg-config clang libhwloc-dev ocl-icd-opencl-dev build-essential hwloc -y

ENV CGO_CFLAGS="-D__BLST_PORTABLE__"
ENV RUSTFLAGS="-C target-cpu=native -g"
ENV FFI_BUILD_FROM_SOURCE=1

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

RUN git clone https://github.com/filecoin-project/lotus.git --depth 1 --branch $BRANCH && \
    cd lotus && \
    git submodule update --init --recursive && \
    make clean && \
    make $NETWORK lotus-shed lotus-gateway && \
    install -C ./lotus /usr/local/bin/lotus && \
    install -C ./lotus-gateway /usr/local/bin/lotus-gateway && \
    install -C ./lotus-shed /usr/local/bin/lotus-shed

# runtime container stage
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive
#creating cron job to check lotus sync status and restart it if process is killed
RUN  apt-get update && \
     apt-get install curl nano libhwloc-dev -y && \
     rm -rf /var/lib/apt/lists/*

COPY --from=build-env /usr/local/bin/lotus /usr/local/bin/lotus
COPY --from=build-env /usr/local/bin/lotus-gateway /usr/local/bin/lotus-gateway
COPY --from=build-env /usr/local/bin/lotus-shed /usr/local/bin/lotus-shed
COPY --from=build-env /etc/ssl/certs /etc/ssl/certs
COPY --from=build-env /lib/x86_64-linux-gnu /lib/
COPY LOTUS_VERSION /VERSION
# lotus libraries
COPY --from=build-env   /lib/x86_64-linux-gnu/libutil.so.1 \
                        /lib/x86_64-linux-gnu/librt.so.1 \
                        /lib/x86_64-linux-gnu/libgcc_s.so.1 \
                        /lib/x86_64-linux-gnu/libdl.so.2 \
                        /usr/lib/x86_64-linux-gnu/libltdl.so.7 \
                        /usr/lib/x86_64-linux-gnu/libnuma.so.1 \
                        /usr/lib/x86_64-linux-gnu/libhwloc.so.5 /lib/
COPY --from=build-env   /usr/lib/x86_64-linux-gnu/libOpenCL.so.1.0.0 /lib/libOpenCL.so.1
# jq libraries
COPY --from=build-env   /usr/lib/x86_64-linux-gnu/libjq.so.1 /usr/lib/x86_64-linux-gnu/
COPY --from=build-env /usr/lib/x86_64-linux-gnu/libonig.so.5.0.0 /usr/lib/x86_64-linux-gnu/libonig.so.5

# create nonroot user and lotus folder
RUN     adduser --uid 2000 --gecos "" --disabled-password --quiet lotus_user

# copy jq, script/config files
COPY --from=build-env /usr/bin/jq /usr/bin/
COPY config/config.toml /home/lotus_user/config.toml
COPY scripts/healthcheck /bin/
COPY scripts/bash-config scripts/configure scripts/run scripts/launch scripts/ensure /etc/lotus/docker/

USER lotus_user

# API port
EXPOSE 1234/tcp

# P2P port
EXPOSE 1235/tcp

ENTRYPOINT ["/etc/lotus/docker/run"]
