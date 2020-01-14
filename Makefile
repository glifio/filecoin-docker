build:
	docker image build -t openworklabs/lotus:latest -f lotus.dockerfile .

run:
	docker container run --publish 1235:1235 --detach --name lotus openworklabs/lotus:latest
