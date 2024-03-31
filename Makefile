IMAGE_NAME = "registry.i.siriusfrk.ru/homepage:latest"

.PHONY: build
build:
	hugo

.PHONY: image
image:
	docker build --platform=linux/amd64 -t $(IMAGE_NAME) -f deploy/Dockerfile .

.PHONY: push
push:
	docker push $(IMAGE_NAME)

.PHONY: deploy
deploy:
	cd deploy && terraform init -backend-config=backend-config.tfvars && terraform apply -auto-approve && kubectl --context microk8s-cluster -n homepage rollout restart deployment homepage

.PHONY: all
all: build image push deploy
