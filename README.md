


````mermaid
flowchart LR
   A("<img src=''; width='150' height='169' />")-.->B("<img src='scripts/png/protofire.png' width='150' height='169'/>");
   B-.-A;
````




[//]: # (<p align="center">)

[//]: # (  <img width="150" height="169" src="scripts/png/favicon-16x16.png">  <img width="150" height="169" src="scripts/png/protofire.png">)

[//]: # (</p>)

[//]: # (<h1 align="center">)

[//]: # (Glif Docker images are managed by Protofire.io)

[//]: # (</h1>)

[![Slack_channel](https://img.shields.io/badge/Contact_Us-AA_AA?style=plastic&logo=slack&logoColor=%20hsla&label=SLACK%20CHANNEL&labelColor=hex&color=e8e413)](https://filecoinproject.slack.com/archives/C023K7D9GAX)
[![Docker Hub](https://img.shields.io/badge/Images_-AA?style=plastic&logo=docker&label=DOCKER%20HUB&labelColor=hex&color=118df2)](https://hub.docker.com/r/glif/lotus/tags)
[![License Apache 2.0](https://img.shields.io/badge/Apache_2.0-AA?style=plastic&logo=apache&label=LICENSE&labelColor=hex&color=11d4f2)](https://github.com/openworklabs/filecoin-docker/blob/master/LICENSE)
[![Discord](https://img.shields.io/badge/Join_Us-AA?style=plastic&logo=discord&label=DISCORD&labelColor=hex&color=5e17eb)](https://discord.gg/5qsJjsP3Re)




## TL;DR

### Launch Lotus
By default `SNAPSHOTURL` environment variable uses a path for mainnet `https://snapshots.mainnet.filops.net/minimal/latest.zst`. It can be changed in the [.env](.env) file, or add the flag `-e`.
````shell
docker run -d --name=lotus -p 1234:1234 -p 1235:1235 -v $HOME/lotus:$HOME/lotus_user  --env-file .env -e INFRA_LOTUS_DAEMON="true" -e INFRA_SYNC="true" -e INFRA_IMPORT_SNAPSHOT="true" glif/lotus:${IMAGE_TAG}
````
### Launch Lotus with Gateway
By default `SNAPSHOTURL` environment variable uses a path for mainnet. It can be changed in the [.env](.env) file, or add the flag `-e`.
````shell
docker run -d --name=lotus -p 1234:1234 -p 1235:1235 -v $HOME/lotus:$HOME/lotus_user  --env-file .env -e INFRA_LOTUS_GATEWAY="true" -e INFRA_IMPORT_SNAPSHOT="true" -e INFRA_SYNC="true" -e INFRA_LOTUS_DAEMON="true"   glif/lotus:${IMAGE_TAG}
````
### Launch Lotus lite node
By default `FULLNODE_API_INFO` environment variable `wss://wss.node.glif.io/apigw/lotus`. It can be changed in the [.env](.env) file, or add the flag `-e`.
````shell
docker run -d --name=lotus -p 1234:1234 -p 1235:1235 -v $HOME/lotus:$HOME/lotus_user  --env-file .env  -e INFRA_LOTUS_LITE="true" glif/lotus:${IMAGE_TAG}
````
### Launch Lotus with custom key
By default `SNAPSHOTURL` environment variable uses a path for mainnet. It can be changed in the [.env](.env) file, or add the flag `-e`.
We expect that  the Kubernetes secret has been mounted to `/keystore` as a directory.
````shell
docker run -d --name=lotus -p 1234:1234 -p 1235:1235 -v $HOME/lotus:$HOME/lotus_user  --env-file .env  -e INFRA_SECRETVOLUME="true" -e INFRA_PERSISTNODEID="true"  -e INFRA_IMPORT_SNAPSHOT="true" -e INFRA_SYNC="true" -e INFRA_LOTUS_DAEMON="true"  -e INFRA_LOTUS_GATEWAY="true" glif/lotus:${IMAGE_TAG}
````

## Prerequisites

Docker has to be installed on your machine to run containers, follow the official Docker installation guide for your operating system:

- [Install Docker Desktop on Mac](https://docs.docker.com/desktop/install/mac-install/)
- [Install Docker Desktop on Linux](https://docs.docker.com/desktop/install/linux-install/)
- [Install Docker Desktop on Windows](https://docs.docker.com/desktop/install/windows-install/)



##  Use pre-built images

You can find our pre-build images [here](https://hub.docker.com/r/glif/lotus/tags?page=1&ordering=last_updated)\
The naming convention is as follows `glif/lotus:$(BRANCH)-$(NETWORK)-$(ARCH)`\
here:
- BRANCH is a git branch of the selected lotus repository (the official one or our fork [protofire/lotus](https://github.com/protofire/lotus)).
- NETWORK  is the Filecoin network the image is built for. Valid values: lotus (for mainnet) and calibnet.
- ARCH is the CPU architecture of the host machine the image is built for. At the moment we provide images for arm64 and amd64.

Example: `glif/lotus:v1.23.1-rc3-mainnet-arm64`

#### To use the pre-built image you have to do the following:
- Pull the image: `docker pull glif/lotus:${IMAGE_TAG}`\
  Before running the run command you have to specify the `Configuration options` into the [.env](.env) file.
- The run command will look like the following:
````shell
docker run -d --name=lotus -p 1234:1234 -p 1235:1235 -v $HOME/lotus:$HOME/lotus_user  --env-file .env  glif/lotus:${IMAGE_TAG}
````


## Build your own image and run the container

We provide three ways you can build your own images and run the container locally:
- You can build the image using the docker build command in a straight-forward and flexible way.
- You can use the pre-written commands in the Makefile.
- You can use docker-compose.



### Build arguments for image 
| Argument name | Default value                                                       | Purpose                                                                                                                      |
|---------------|---------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------|
| REPOSITORY    | [filecoin-project/lotus](https://github.com/filecoin-project/lotus) | The Git repository to clone the lotus source code from.                                                                      |
|BRANCH| master                                                              | The Git branch of the before-mentioned repository.                                                                           |
|NETWORK| lotus                                                               | The Filecoin network to build the image for. Acceptable values: lotus (for mainnet) and calibnet.                            |



### Configuration options to run the container, follow to the file [.env](.env)

| Environment variables | What data does it accept?                                                                                                                                                                           | What is it for?                                                                                                                                                                                                                                                                                                                                                                             |
|-----------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| INFRA_LOTUS_DAEMON    | TRUE or FALSE                                                                                                                                                                                       | Set it to TRUE to start the lotus daemon only.                                                                                                                                                                                                                                                                                                                                              |
| INFA_LOTUS_GATEWAY    | TRUE or FALSE                                                                                                                                                                                       | Set it to TRUE to start the lotus daemon with the lotus gateway on top.                                                                                                                                                                                                                                                                                                                     |
| INFRA_CLEAR_RESTART   | TRUE or FALSE                                                                                                                                                                                       | Set it to TRUE to remove the lotus folder. Useful when resetting the node.                                                                                                                                                                                                                                                                                                                  |
| INFRA_IMPORT_SNAPSHOT | TRUE or FALSE                                                                                                                                                                                       | Set it to TRUE to import the snapshot from the URL specified in the SNAPSHOTURL environment variable.                                                                                                                                                                                                                                                                                       |
| INFRA_LOTUS_HOME      | Path in the container’s filesystem. Default is: /home/lotus_user                                                                                                                                    | Defines where in the container’s filesystem the .lotus folder will be created.                                                                                                                                                                                                                                                                                                              |                                                                                                                    ||
| INFRA_PERSISTNODEID   | TRUE or FALSE                                                                                                                                                                                       | Set it to TRUE to copy the node ID from `/keystore/nodeid` to `$LOTUS_PATH/keystore/NRUWE4BSOAWWQ33TOQ`. This is needed for bootstrap node.                                                                                                                                                                                                                                                 |
| INFRA_SECRETVOLUME    | TRUE or FALSE                                                                                                                                                                                       | Set it to TRUE to copy the AUTH token from `/keystore/token` to `$LOTUS_PATH/token` and to copy the private_key from `/keystore/privatekey` to `$LOTUS_PATH/keystore/MF2XI2BNNJ3XILLQOJUXMYLUMU`. That implies that the Kubernetes secret has been mounted to `/keystore` as a directory. That allows using the same authentication token despite the node being reset over and over again. |
| INFRA_SYNC            | TRUE or FALSE                                                                                                                                                                                       | Set it to TRUE for the Lotus blockchain sync before the actual Lotus Daemon starts. Example of usage - Liveness probe in the k8s - you are waiting for the file `$INFRA_LOTUS_HOME/.lotus/sync-complete` and only after the file creation you add Lotus pod to the k8s service.                                                                                                             |
| SNAPSHOTURL           | URL to the snapshot. The current recent state snapshots are available here: https://snapshots.mainnet.filops.net/minimal/latest.zst, https://snapshots.calibrationnet.filops.net/minimal/latest.zst | Set it to TRUE snapshot URL to make lotus download and import it. Can also be a path in the container’s filesystem.                                                                                                                                                                                                                                                                         |
| INFRA_LOTUS_LITE      | TRUE or FALSE                                                                                                                                                                                       | Set it to TRUE to run the lotus daemon in the lite node mode.                                                                                                                                                                                                                                                                                                                               |
| FULLNODE_API_INFO     | URL of the full node: `wss://wss.node.glif.io/apigw/lotus`                                                                                                                                          | You have to specify this variable if `INFRA_LOTUS_LITE` is set to true.                                                                                                                                                                                                                                                                                                                     |




## Common configuration examples

This section describes a few scenarios of how you can use the environment variables to achieve different results, e.g.\
running the spot recent state node, running the on-demand state node, running the lotus lite node, running the node outside of Kubernetes, etc.

#### Running the spot recent state node


When we use `INFRA_CLEAR_RESTART=true`, we expect that directory lotus is removed upon the start of the container. Then, if `INFRA_IMPORT_SNAPSHOT=true` and the `SNAPSHOTURL` is specified, the container will attempt to download and import the snapshot.

- The list of env variables you should change into the file [.env](.env) is as follows, you can find more details about the environment variables in the `Configuration options` section.


````
INFRA_CLEAR_RESTART=true
INFRA_IMPORT_SNAPSHOT=true
INFRA_LOTUS_DAEMON=true
INFRA_LOTUS_GATEWAY=true
INFRA_PERSISTNODEID=false
INFRA_SECRETVOLUME=false
INFRA_SYNC=true
SNAPSHOTURL=https://snapshots.mainnet.filops.net/minimal/latest.zst
````

#### Running the on-demand state node

When we use `INFRA_CLEAR_RESTART=false`, we expect that directory lotus isn't removed upon the container start and data will continue to sync from the moment the sync was interrupted.

- The list of env variables you should change into the file [.env](.env) is the following, you can find more details about the environment variables if follow the link `Configuration options`.


````
INFRA_CLEAR_RESTART=false
INFRA_IMPORT_SNAPSHOT=true
INFRA_LOTUS_DAEMON=true
INFRA_LOTUS_GATEWAY=true
INFRA_PERSISTNODEID=false
INFRA_SECRETVOLUME=false
INFRA_SYNC=true
SNAPSHOTURL=https://snapshots.mainnet.filops.net/minimal/latest.zst
````


### Using the docker build command
The Dockerfile requires you to specify the following build arguments: `BRANCH`, `NETWORK`, `REPOSITORY`.  You can override the default values using the `—build-arg flag` in the docker build command. Example:
By default TAG of the image has the naming `glif/lotus:$(BRANCH)-$(NETWORK)`, you can change it to your custom TAG like `-t  ${IMAGE_TAG}`. By the way, this parameter is `OPTIONAL`.

- You can build the image using the following command:
```shell
   docker image build --network host --build-arg NETWORK=$(NETWORK) --build-arg BRANCH=$(BRANCH) -t glif/lotus:$(BRANCH)-$(NETWORK) .
````


### Run the container using the docker command

Before running the run command you have to specify the `Configuration options`.
You can build and use `your own image` or [use our pre built images](#use-pre-built-images) when specifying the image.

- The run command will look like the following:
```shell
   docker run -d --name=lotus -p 1234:1234 -p 1235:1235 -v $HOME/lotus:$HOME/lotus_user  --env-file .env  glif/lotus:${IMAGE_TAG}
````


### Using the Makefile

Before running any commands provided by the [Makefile](Makefile), you have to specify the `build arguments`.\
You have to also specify the `ARCH` argument - it’s the CPU architecture of the host machine the image is built for. The acceptable values are: `arm64, amd64`.\
The image TAG will have the name like `glif/lotus:$(BRANCH)-$(NETWORK)-$(ARCH)`, you can change it in the Makefile the `build` section to your custom TAG like `-t  ${IMAGE_TAG}`. By the way, this parameter is `OPTIONAL`.

- Then you could run the following command in your terminal:

````shell
   make build
````


### Run the container using the Makefile

Before running any commands provided by the [Makefile](Makefile), you have to specify the `Configuration options`.

The image that the Makefile builds looks like the following: `glif/lotus:$(BRANCH)-$(NETWORK)-$(ARCH)`, If you'd like to use a custom image, you can edit the Makefile the `run` section.

Example for usage Makefile :

````
	docker run -d --name lotus \
	-p 1234:1234 -p 1235:1235 \
     --env-file .env \
	--network host \
	--restart always \
	--mount type=bind,source=$(SOURCE_DIR),target=/home/lotus_user \
	 glif/lotus:latest

````

````shell
  make run
````


### Using docker-compose

While running the build command you have to specify the `build arguments`.
By default TAG of the image has the naming `glif/lotus:latest`, you can change it in the file [docker-compose](docker-compose.yaml) in the section `image` to your custom TAG.

- The build command will look like the following:
```shell
   docker-compose build --build-arg NETWORK=calibnet --build-arg BRANCH=master
````

###  run the container using the docker-compose

Before running the run command you have to specify the `Configuration options`.

-  Build and run docker the container

````shell
  docker-compose up -d --build
````
- Verify that the container is running with the following command:

```shell
  docker ps
```



## Troubleshooting

#### Problem:
`cp: cannot stat '/keystore/token': No such file or directory`

#### Symptoms:
if you look this in the container logs:

````
===> Configuring ...
I'll remove ALL LOTUS DATA from /home/lotus_user/.lotus/
-------> Removing ... <---------
cp: cannot stat '/keystore/token': No such file or directory

````

#### Solution:

- Make sure that variables `INFRA_SECRETVOLUME`, `INFRA_PERSISTNODEID` have a value `false` into the file [.env](.env).
- if secrets are used by Kubernetes:
  -  make sure that the secret volume is really mounted `$LOTUS_PATH/keystore`
  -  make sure that the secrets are correct  `/home/lotus_user/.lotus/token`, `/home/lotus_user/.lotus/keystore/${private_key}`, `/home/lotus_user/.lotus/keystore/${node_id}`
-------------------

- [Use pre-built images](#use-pre-built-images)
- [Build image and run the container](#build-your-own-image-and-run-the-container)
  - [Common configuration examples](#common-configuration-examples)
  - [Using the docker command](#using-the-docker-build-command)
  - [Using the Makefile](#using-the-makefile)
  - [Using docker-compose](#using-docker-compose)
- [Troubleshooting](#troubleshooting)


## Summary

This repository contains Docker manifest and the set of scripts that you can use to run the Lotus container.

Why do we use custom scripts?

- We’ve been hosting lotus in Kubernetes for 3+ years (in comparison the official lotus images have been existing for only 2 years at the moment), and as a result of our accumulated experience we’ve developed a set of scripts tailored specifically for our needs, e.g. copying Lotus tokens from Kubernetes secrets, resetting the recent state nodes when their storage is full, etc

Why do we build our own images?

- We've optimized Lotus images by using only the necessary libraries and binaries, like `lotus, lotus-gateway, lotus-shed`

What launch scenarios do we support out-of-the-box?

- We support the following launch scenarios:
  - launching the Lotus daemon only
  - launching the Lotus daemon with lotus gateway
  - launching a Lotus Lite node

  
## Structure 

Here's a quick guide. The main parts of the repository are:

* [Dockerfile](./Dockerfile) - contains the necessary configuration to build the image and embed the scripts.
* [config.toml](./config/config.toml) - the lotus configuration file. Contains only the parameters that cannot be set by the environment variables.
* [Our infrastructure scripts:](./scripts) - contains scripts to build and run Lotus.
* [Makefile](./Makefile) - contains a set of commands for building the Lotus image, running and operating the Lotus container.
* [Docker-compose](./docker-compose.yaml) - contains a set of parameters for building the Lotus image and running the Lotus container in a docker-compose fashion.

If you want to understand better scripts structure and how it works, please follow the link [Structure](scripts/README-Structure.md)

## Contact Us

- [Website](http://glif.io/)
- [GitHub](https://github.com/glifio)
- [Docker Hub](https://hub.docker.com/r/glif/lotus/tags)
