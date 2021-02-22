# filecoin-docker

[![CircleCI](https://circleci.com/gh/glifio/filecoin-docker.svg?style=svg)](https://circleci.com/gh/openworklabs/filecoin-docker)

A Docker image for [Lotus](https://github.com/filecoin-project/lotus) Filecoin nodes.

## Getting Started

These instructions will cover usage information and for the docker container

### Prerequisities

In order to run this container you'll need docker installed.

- [Windows](https://docs.docker.com/windows/started)
- [OS X](https://docs.docker.com/mac/started/)
- [Linux](https://docs.docker.com/linux/started/)

### Usage

```shell
## Build the Docker image
make build
## Run the Docker container
make run
```
or
```shell
## Build the Docker image
docker-compose build
## Run the Docker container
## Set TAG before up
docker-compose up -d
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
- `INFRA_LOTUS_HOME` - Define lotus home dir
- `INFRA_IMPORT_SNAPSHOT` - Set true for import snapshot
- `SNAPSHOTURL` - SNAPSHOT URL (https://...)
- `INFRA_LOTUS_DAEMON` - Set true to start daemon after configure


#### Volumes

- `/home/lotus_user/.lotus` - lotus main folder

#### Useful File Locations

- `/scripts/run` - Docker entrypoint script

## Dependencies

- ubuntu:18.04
- golang:1.13
- git
- mesa-opencl-icd
- ocl-icd-opencl-dev
- gcc
- bzr
- jq
- Lotus

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

List of `tag` you may find in [lotus repository](https://github.com/filecoin-project/lotus/tags)

It works with next tags:
* v*
* ntwk-*

New version is available in [Docker Hub](https://hub.docker.com/r/openworklabs/lotus/tags)
## Find Us

- [Website](https://www.openworklabs.com)
- [GitHub](https://github.com/openworklabs)
- [Docker Hub](https://hub.docker.com/orgs/openworklabs/repositories)

## License

This project is licensed under the [Apache 2.0](https://github.com/openworklabs/filecoin-docker/blob/master/LICENSE) license.
