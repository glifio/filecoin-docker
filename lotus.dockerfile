# build container stage
FROM golang:1.13 AS build-env
RUN apt-get update -y && \
    apt-get install sudo curl git mesa-opencl-icd ocl-icd-opencl-dev gcc git bzr jq pkg-config -y
RUN git clone https://github.com/filecoin-project/lotus.git && \
    cd lotus && \
    git pull && \
    git checkout master && \
    make clean && \
    make all && \
    make install

# runtime container stage
FROM ubuntu:18.04
RUN apt-get update -y && \
    apt-get install sudo ca-certificates mesa-opencl-icd ocl-icd-opencl-dev -y
COPY --from=build-env /usr/local/bin/lotus /usr/local/bin/lotus
COPY LOTUS_VERSION /VERSION
COPY config/config.toml /root/.lotus/config.toml
COPY scripts/entrypoint /bin/entrypoint
EXPOSE 1235/tcp
EXPOSE 1234/tcp
ENTRYPOINT ["/bin/entrypoint"]