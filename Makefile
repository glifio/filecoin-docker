# Git branch of the lotus repository
BRANCH = master
# Filecoin network. Valid values: lotus(mainnet), calibnet
NETWORK := lotus
# Image build architecture
ARCH = arm64
# Lotus repository
SOURCE_DIR = "$(HOME)/lotus"


# Image build

.PHONY: build
build:
	docker image build --network host --build-arg NETWORK=$(NETWORK) --build-arg BRANCH=$(BRANCH) -t glif/lotus:$(BRANCH)-$(NETWORK)-$(ARCH) .

.PHONY: rebuild
rebuild:
	docker image build --no-cache  --network host --build-arg NETWORK=$(NETWORK) --build-arg BRANCH=$(BRANCH) -t glif/lotus:$(BRANCH)-$(NETWORK)-$(ARCH) .

.PHONY: push
push:
	docker push -t glif/lotus:$(BRANCH)-$(NETWORK)-$(ARCH)


git-push:
	git commit -a -m "$(BRANCH)" && git push && git tag $(BRANCH) && git push --tags

# Run docker container

.PHONY: run
run:
	docker run -d --name lotus \
	-p 1234:1234 -p 1235:1235 \
     --env-file .env \
	--network host \
	--restart always \
	--mount type=bind,source=$(SOURCE_DIR),target=/home/lotus_user \
	 glif/lotus:$(BRANCH)-$(NETWORK)-$(ARCH)


run-bash:
	docker container run -p 1235:1235 -p 1234:1234 -it --entrypoint=/bin/bash --name lotus --rm glif/lotus:$(BRANCH)-$(NETWORK)-$(ARCH)

bash:
	docker exec -it lotus /bin/bash

sync-status:
	docker exec -it lotus lotus sync status

log:
	docker logs lotus -f

rm:
	docker stop lotus
	docker rm lotus
