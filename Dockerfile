# build container stage
FROM golang:1.14.2 AS build-env

# branch or tag of the lotus version to build
ARG BRANCH

RUN echo "Building lotus from branch $BRANCH"

RUN apt-get update -y && \
    apt-get install sudo cron git mesa-opencl-icd ocl-icd-opencl-dev gcc git bzr jq pkg-config clang -y

ENV RUSTFLAGS="-C target-cpu=native -g"
ENV FFI_BUILD_FROM_SOURCE=1

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

RUN git clone https://github.com/filecoin-project/lotus.git --depth 1 --branch $BRANCH && \
    cd lotus && \
    make clean && \
    make lotus lotus-shed && \
    install -C ./lotus /usr/local/bin/lotus && \
    install -C ./lotus-shed /usr/local/bin/lotus-shed

# runtime container stage
FROM ubuntu:18.04

#creating cron job to check lotus sync status and restart it if process is killed
RUN  mkdir /etc/cron.d && \
     mkdir -p /var/spool/cron/crontabs && \
     apt-get update && \
     apt-get install curl -y && \
     rm -rf /var/lib/apt/lists/*
COPY scripts/cron /etc/cron.d/
COPY --from=build-env /usr/bin/crontab /usr/bin/crontab
COPY --from=build-env /etc/init.d/cron /etc/init.d/cron
COPY --from=build-env /usr/sbin/cron /usr/sbin/cron
COPY scripts/lotus-sync-restart scripts/lotus-export  /bin/

RUN  crontab -u root /etc/cron.d/cron

COPY --from=build-env /usr/local/bin/lotus /usr/local/bin/lotus
COPY --from=build-env /usr/local/bin/lotus-shed /usr/local/bin/lotus-shed
COPY --from=build-env /etc/ssl/certs /etc/ssl/certs
COPY --from=build-env /lib/x86_64-linux-gnu /lib/
COPY LOTUS_VERSION /VERSION
# lotus libraries
COPY --from=build-env   /lib/x86_64-linux-gnu/libutil.so.1 /lib/x86_64-linux-gnu/librt.so.1 \
                        /lib/x86_64-linux-gnu/libgcc_s.so.1 /lib/x86_64-linux-gnu/libdl.so.2 /lib/
COPY --from=build-env   /usr/lib/x86_64-linux-gnu/libOpenCL.so.1.0.0 /lib/libOpenCL.so.1
# jq libraries
COPY --from=build-env   /usr/lib/x86_64-linux-gnu/libjq.so.1 /usr/lib/x86_64-linux-gnu/
COPY --from=build-env /usr/lib/x86_64-linux-gnu/libonig.so.5.0.0 /usr/lib/x86_64-linux-gnu/libonig.so.5

COPY --from=build-env /usr/bin/jq /usr/bin/
COPY config/config.toml /root/config.toml
COPY scripts/entrypoint scripts/healthcheck /bin/

ADD https://raw.githubusercontent.com/filecoin-project/network-info/master/static/networks/butterfly.json /networks/
ADD https://raw.githubusercontent.com/filecoin-project/network-info/master/static/networks/calibration.json /networks/
ADD https://raw.githubusercontent.com/filecoin-project/network-info/master/static/networks/mainnet.json /networks/
ADD https://raw.githubusercontent.com/filecoin-project/network-info/master/static/networks/nerpa.json /networks/

# API port
EXPOSE 1234/tcp

# P2P port
EXPOSE 1235/tcp

ENTRYPOINT ["/bin/entrypoint"]
CMD ["-d"]
