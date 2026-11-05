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
	@echo "Manifests are k8s/homepage in home-infrastructure: commit there, then Sync in Argo CD."

.PHONY: rollout
rollout:
	kubectl --context microk8s -n homepage rollout restart deployment homepage

.PHONY: all
all: build image push deploy
