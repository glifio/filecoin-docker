BRANCH = v0.4.1

.PHONY: build
build:
	docker image build --build-arg BRANCH=$(BRANCH) -t openworklabs/lotus:$(BRANCH) . 

.PHONY: rebuild
rebuild:
	docker image build --no-cache --build-arg BRANCH=$(BRANCH) -t openworklabs/lotus:$(BRANCH) . 

.PHONY: push
push:
	docker push openworklabs/lotus:$(BRANCH)

tag: tag_lotus

build_lotus:
	./build/build_lotus.sh

rebuild_lotus:
	./build/build_lotus.sh rebuild

tag_lotus:
	./build/tag_lotus.sh

.PHONY: run
run:
	docker run --detach \
	--publish 1234:1234 \
	--name lotus \
	--restart always \
	--volume $(HOME)/.lotus:/root/.lotus \
	openworklabs/lotus:$(BRANCH)

run-bash:
	docker container run -p 1235:1235 -p 1234:1234 -it --entrypoint=/bin/bash --name lotus --rm openworklabs/lotus:latest

bash:
	docker exec -it lotus /bin/bash

sync-status:
	docker exec -it lotus lotus sync status

log:
	docker logs lotus -f

rm:
	docker stop lotus
	docker rm lotus
