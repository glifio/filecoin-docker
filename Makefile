build:
	docker image build -t openworklabs/lotus:latest -f lotus.dockerfile .

rebuild:
	docker image build --no-cache -t openworklabs/lotus:latest -f lotus.dockerfile .

run:
	docker container run -p 1235:1235 -p 1234:1234 --dns 8.8.8.8 --dns-search example.com --detach --name lotus openworklabs/lotus:latest

bash:
	docker container run -p 1235:1235 -p 1234:1234 -it --entrypoint=/bin/bash --name lotus --rm openworklabs/lotus:latest

