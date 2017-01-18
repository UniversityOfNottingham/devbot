VERSION ?= dev

.PHONY: build push
build: build-devbot
push: push-devbot

.PHONY: build-devbot
build-devbot:
	docker build -t nottinghamuniversity/devbot:$(VERSION) devbot/

.PHONY: push-devbot
push-devbot:
	docker push nottinghamuniversity/devbot:$(VERSION)

.PHONY: release
release: release-devbot

.PHONY: release-devbot
release-devbot:
	docker tag nottinghamuniversity/devbot:$(VERSION) nottinghamuniversity/devbot:latest
	docker push nottinghamuniversity/devbot:latest