# filecoin-docker

[![CircleCI](https://circleci.com/gh/glifio/filecoin-docker.svg?style=svg)](https://app.circleci.com/pipelines/github/glifio/filecoin-docker)

A Docker image for [Lotus](https://github.com/filecoin-project/lotus) Filecoin nodes.

The have actual images in our [docker hub](https://hub.docker.com/r/glif/lotus/tags?page=1&ordering=last_updated) (intel CPU only)

## Getting Started

These instructions will cover usage information and for the docker container

### Prerequisities

In order to run this container you'll need docker installed.

- [OS X](https://docs.docker.com/mac/started/)
- [Linux](https://docs.docker.com/linux/started/)

### Usage

### mainnet from snapshot
```shell
## Build the Docker image for mainnet
    make build
## Create folder and run the Docker container with mainnet
    mkdir -p $HOME/lotus && sudo chown -R 2000:2000 $HOME/lotus
    make run
```
### calibrationnet from scratch
```shell
## Build the Docker image for calibrationnet
    make -e NETWORK=calibnet build
## Create folder and run the Docker container with calibrationnet
    mkdir -p $HOME/lotus && sudo chown -R 2000:2000 $HOME/lotus
    make run-calibnet
```
### nerpanet from snapshot
```shell
## Build the Docker image for nerpanet
    make -e NETWORK=nerpanet build
## Create folder and run the Docker container with calibrationnet
    mkdir -p $HOME/lotus && sudo chown -R 2000:2000 $HOME/lotus
    make run-nerpanet
```
or using our [image](https://hub.docker.com/r/glif/lotus/tags?page=1&ordering=last_updated) (intel cpu only)

mainnet
```
mkdir -p $HOME/lotus && sudo chown -R 2000:2000 $HOME/lotus
docker run -d --name lotus \
-p 1234:1234 -p 1235:1235 \
-e INFRA_LOTUS_DAEMON="true" \
-e INFRA_LOTUS_HOME="/home/lotus_user" \
-e INFRA_IMPORT_SNAPSHOT="true" \
-e SNAPSHOTURL="https://fil-chain-snapshots-fallback.s3.amazonaws.com/mainnet/minimal_finality_stateroots_latest.car" \
-e INFRA_SYNC="true" \
--network host \
-v $HOME/lotus:/home/lotus_user \
glif/lotus:v1.11.0
```
nerpanet
```
mkdir -p $HOME/lotus && sudo chown -R 2000:2000 $HOME/lotus
docker run -d --name lotus \
-p 1234:1234 -p 1235:1235 \
-e INFRA_LOTUS_DAEMON="true" \
-e INFRA_LOTUS_HOME="/home/lotus_user" \
-e INFRA_IMPORT_SNAPSHOT="true" \
-e SNAPSHOTURL="https://dev.node.glif.io/nerpa00/ipfs/8080/ipfs/$(curl -s https://gist.githubusercontent.com/openworklabbot/d32543d42ed318f6dfde516c3d8668a0/raw/snapshot.log)" \
-e INFRA_SYNC="true" \
--network host \
-v $HOME/lotus:/home/lotus_user \
glif/lotus:nerpa-v1.11.1-dev-nerpanet
```
or with [docker-compose](https://docs.docker.com/compose/install/)

### mainnet from snapshot
```shell
## Create folder
mkdir -p $HOME/lotus && sudo chown -R 2000:2000 $HOME/lotus
## Build and run docker container
docker-compose up -d --build
```

### nerpanet from snapshot
```shell
## Create folder
mkdir -p $HOME/lotus && sudo chown -R 2000:2000 $HOME/lotus
## Update environment
bash ./docker-compose-nerpanet-variable.sh
## Build and run docker container
docker-compose -f docker-compose-nerpanet.yaml up -d --build
```

Verify that the container is running successfully with:

```shell
docker ps
```

#### Environment Variables

- `BRANCH` - The git release, tag or branch
- `LOTUS_EXPORT` - Set to true if you want to export chain snapshots on a daily basis somewhere
- `LOTUS_EXPORT_PATH` - If LOTUS_EXPORT is set to true - specify whether `.car` file should be saved
- `INFRA_SHEDEXPORT` - Set to true if you want to export chain snapshots using `lotus-shed`
- `INFRA_SHEDEXPORTPERIOD` - Defines period of chain snapshotting. Examples: 1m, 1h, 1d
- `INFRA_SHEDEXPORTPATH` - Defines path where to export chain snapshot
- `INFRA_CLEAR_RESTART` - Set true if you want to remove all data when container will fail
- `INFRA_LOTUS_DAEMON` - Set true to start daemon after configure
- `INFRA_LOTUS_GATEWAY` - Set true to start lotus gateway service.
- `INFRA_LOTUS_HOME` - Define lotus home dir
- `INFRA_LOTUS_LITE` - Set true to start lotus [lite](https://docs.filecoin.io/build/lotus/lotus-lite/#start-the-lite-node) mode
    - `FULLNODE_API_INFO` - Set if you want to start lotus in [lite](https://docs.filecoin.io/build/lotus/lotus-lite/#start-the-lite-node) mode.
- `INFRA_IMPORT_SNAPSHOT` - Set true for import snapshot
- `SNAPSHOTURL` - SNAPSHOT URL (https://...)

#### Volumes

- `/home/lotus_user/.lotus` - lotus main folder

#### Useful File Locations

- `/scripts/run` - Docker entrypoint script

## Dependencies

- golang:1.16.5
- git
- mesa-opencl-icd
- ocl-icd-opencl-dev
- gcc
- bzr
- jq
- pkg-config 
- clang  
- libhwloc-dev 
- ocl-icd-opencl-dev

## Automatic build in docker hub

If you want to start automatic build in Docker Hub, you have to:

- change variable `ARG BRANCH` in `Dockerfile`, push changes, create new tag, push tag to repository

or
- change variable `ARG BRANCH` in `Dockerfile`, `BRANCH` in `Makefile` and execute `make git-push`

If you want run build manually from master branch, you have to change variable `ARG BRANCH`
 in `Dockerfile` push to repository, start build on Docker Hub web page.

Example:

    git commit -a -m "ntwk-butterfly-7.10.0" && git push && \
    git tag ntwk-butterfly-7.10.0 && git push --tags

List of `tag` you may find on [lotus repository](https://github.com/filecoin-project/lotus/tags)

New version is available on [Docker Hub](https://hub.docker.com/r/glif/lotus/tags)

Docker image contains:
- ubuntu:18.04
- curl 
- nano 
- libhwloc-dev 
- lotus
- lotus-shed
- lotus-gateway

## Find Us

- [Website](http://glif.io/)
- [GitHub](https://github.com/glifio)
- [Docker Hub](https://hub.docker.com/r/glif/lotus/tags)

## License

This project is licensed under the [Apache 2.0](https://github.com/openworklabs/filecoin-docker/blob/master/LICENSE) license.
