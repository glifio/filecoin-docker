BRANCH = master
NETWORK := lotus
SOURCE_DIR = "$(HOME)/lotus"

.PHONY: build
build:
	docker image build --network host --build-arg NETWORK=$(NETWORK) --build-arg BRANCH=$(BRANCH) -t glif/lotus:$(BRANCH) .

.PHONY: rebuild
rebuild:
	docker image build --no-cache  --network host --build-arg NETWORK=$(NETWORK) --build-arg BRANCH=$(BRANCH) -t glif/lotus:$(BRANCH) .

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
	docker run -d --name lotus \
	-p 1234:1234 -p 1235:1235 \
	-e INFRA_LOTUS_DAEMON="true" \
	-e INFRA_LOTUS_HOME="/home/lotus_user" \
	-e INFRA_IMPORT_SNAPSHOT="true" \
	-e SNAPSHOTURL="https://fil-chain-snapshots-fallback.s3.amazonaws.com/mainnet/minimal_finality_stateroots_latest.car" \
	-e INFRA_SYNC="true" \
	--network host \
	--restart always \
	--mount type=bind,source=$(SOURCE_DIR),target=/home/lotus_user \
	glif/lotus:$(BRANCH)

.PHONY: run-calibnet
run-calibnet:
	docker run -d --name lotus \
	-p 1234:1234 -p 1235:1235 \
	-e INFRA_LOTUS_DAEMON="true" \
	-e INFRA_LOTUS_HOME="/home/lotus_user" \
	-e INFRA_SYNC="true" \
	--network host \
	--restart always \
	--mount type=bind,source=$(SOURCE_DIR),target=/home/lotus_user \
	glif/lotus:$(BRANCH)

.PHONY: run-nerpanet
run-nerpanet:
	docker run -d --name lotus \
	-p 1234:1234 -p 1235:1235 \
	-e INFRA_LOTUS_DAEMON="true" \
	-e INFRA_LOTUS_HOME="/home/lotus_user" \
	-e INFRA_IMPORT_SNAPSHOT="true" \
	-e SNAPSHOTURL="https://dev.node.glif.io/nerpa00/ipfs/8080/ipfs/$(curl -s https://gist.githubusercontent.com/openworklabbot/d32543d42ed318f6dfde516c3d8668a0/raw/snapshot.log)" \
	-e INFRA_SYNC="true" \
	--network host \
	--restart always \
	--mount type=bind,source=$(SOURCE_DIR),target=/home/lotus_user \
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
