build:
	docker image build -t openworklabs/lotus:latest -f lotus.dockerfile .

rebuild:
	docker image build --no-cache -t openworklabs/lotus:latest -f lotus.dockerfile .

run:
	docker container run --publish 1235:1235 --detach --name lotus openworklabs/lotus:latest

bash:
	docker container run --publish 1235:1235 -it --entrypoint=/bin/bash --name lotus --rm openworklabs/lotus:latest

