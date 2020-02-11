# build container stage
FROM golang:1.13 AS build-env
RUN apt-get update -y && \
    apt-get install sudo curl git mesa-opencl-icd ocl-icd-opencl-dev gcc git bzr jq pkg-config -y
RUN git clone https://github.com/filecoin-project/lotus.git && \
    cd lotus && \
    git pull && \
    git fetch --tags && \
    latestTag=$(git describe --tags `git rev-list --tags --max-count=1`) && \
    git checkout $latestTag && \
    make clean && \
    make lotus chainwatch && \
    install -C ./lotus /usr/local/bin/lotus && \
    install -C ./chainwatch /usr/local/bin/chainwatch

# runtime container stage
FROM ubuntu:18.04
#RUN apt-get update && \
#    apt-get install sudo ca-certificates mesa-opencl-icd ocl-icd-opencl-dev -y && \
#    rm -rf /var/lib/apt/lists/*
COPY --from=build-env /usr/local/bin/lotus /usr/local/bin/lotus
COPY --from=build-env /usr/local/bin/chainwatch /usr/local/bin/chainwatch
COPY --from=build-env /etc/ssl/certs /etc/ssl/certs
COPY LOTUS_VERSION /VERSION

COPY --from=build-env /lib/x86_64-linux-gnu/libdl.so.2 /lib/libdl.so.2
COPY --from=build-env /lib/x86_64-linux-gnu/libutil.so.1 /lib/libutil.so.1 
COPY --from=build-env /usr/lib/x86_64-linux-gnu/libOpenCL.so.1.0.0 /lib/libOpenCL.so.1
COPY --from=build-env /lib/x86_64-linux-gnu/librt.so.1 /lib/librt.so.1
COPY --from=build-env /lib/x86_64-linux-gnu/libgcc_s.so.1 /lib/libgcc_s.so.1

COPY config/config.toml /root/config.toml
COPY scripts/entrypoint /bin/entrypoint

# API port
EXPOSE 1234/tcp

# P2P port
EXPOSE 1235/tcp

ENTRYPOINT ["/bin/entrypoint"]
