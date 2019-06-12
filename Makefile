docker_registry = honigwasser
name = webapp
tag = 8.12.0

.PHONY: build

all: build

build:
	docker build -t $(docker_registry)/$(name) .
	docker tag $(docker_registry)/$(name) $(docker_registry)/$(name):$(tag)

run:
	docker run -it $(docker_registry)/$(name):$(tag) bash -l

push:
	./push-to-registry.sh $(docker_registry)/$(name):$(tag)
