# filecoin-docker

[![CircleCI](https://circleci.com/gh/openworklabs/filecoin-docker.svg?style=svg)](https://circleci.com/gh/openworklabs/filecoin-docker)

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

Verify that the container is running successfully with:

```shell
docker ps
```

#### Environment Variables

- `BRANCH` - The git release, tag or branch

#### Volumes

- `/root/.lotus` - lotus main folder

#### Useful File Locations

- `/script/entrypoint` - Docker entrypoint script

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

## Find Us

- [Website](www.openworklabs.com)
- [GitHub](https://github.com/openworklabs)
- [Docker Hub](https://hub.docker.com/orgs/openworklabs/repositories)

## License

This project is licensed under the [Apache 2.0](https://github.com/openworklabs/filecoin-docker/blob/master/LICENSE) license.
