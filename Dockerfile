# build container stage
FROM golang:1.14.2 AS build-env

# branch or tag of the lotus version to build
ARG BRANCH=v0.5.10

RUN echo "Building lotus from branch $BRANCH"

RUN apt-get update -y && \
    apt-get install sudo cron git mesa-opencl-icd ocl-icd-opencl-dev gcc git bzr jq bc pkg-config -y

RUN git clone https://github.com/filecoin-project/lotus.git --depth 1 --branch $BRANCH && \
    cd lotus && \
    make clean && \
    make lotus && \
    install -C ./lotus /usr/local/bin/lotus

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

COPY --from=build-env /usr/bin/jq /usr/bin/bc /usr/bin/
COPY config/config.toml /root/config.toml
COPY scripts/entrypoint scripts/healthcheck /bin/

# API port
EXPOSE 1234/tcp

# P2P port
EXPOSE 1235/tcp

ENTRYPOINT ["/bin/entrypoint"]
CMD ["-d"]
