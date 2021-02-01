BRANCH = master
NETWORK= lotus

.PHONY: build
build:
	docker image build --no-cache --build-arg NETWORK=$NETWORK --build-arg BRANCH=$latestLotusTag -t glif/lotus:$imageTag .

build_host:
	docker image build --no-cache  --network host --build-arg NETWORK=$NETWORK --build-arg BRANCH=$latestLotusTag -t glif/lotus:$imageTag .

.PHONY: rebuild
rebuild:
	docker image build --no-cache  --network host --build-arg NETWORK=$NETWORK --build-arg BRANCH=$latestLotusTag -t glif/lotus:$imageTag . 

.PHONY: push
push:
	docker push glif/lotus:$(BRANCH)

build_lotus:
	./build/build_lotus.sh

rebuild_lotus:
	./build/build_lotus.sh rebuild

git-push:
	git commit -a -m "$(BRANCH)" && git push && git tag $(BRANCH) && git push --tags

.PHONY: run
run:
	docker run --detach \
	--publish 1234:1234 \
	--name lotus \
	--restart always \
	--volume $(HOME)/.lotus:/home/lotus_user/.lotus \
	glif/lotus:$(BRANCH)

run-bash:
	docker container run -p 1235:1235 -p 1234:1234 -it --entrypoint=/bin/bash --name lotus --rm glif/lotus:latest

bash:
	docker exec -it lotus /bin/bash

sync-status:
	docker exec -it lotus lotus sync status

log:
	docker logs lotus -f

rm:
	docker stop lotus
	docker rm lotus
