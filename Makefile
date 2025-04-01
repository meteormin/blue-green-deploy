PRJ_NAME=blue-green-deploy
AUTHOR="Meteormin \(miniyu97@gmail.com\)"
PRJ_BASE=$(shell pwd)
PRJ_DESC=$(PRJ_NAME) Deployment and Development Makefile.\n Author: $(AUTHOR)

SUPPORTED_OS=linux darwin
SUPPORTED_ARCH=amd64 arm64

.DEFAULT: help
.SILENT:;

##help: helps (default)
.PHONY: help
help: Makefile
	echo ""
	echo " $(PRJ_DESC)"
	echo ""
	echo " Usage:"
	echo ""
	echo "	make {command}"
	echo ""
	echo " Commands:"
	echo ""
	sed -n 's/^##/	/p' $< | column -t -s ':' |  sed -e 's/^/ /'
	echo ""

# OS와 ARCH가 정의되어 있지 않으면 기본값을 설정합니다.
# uname -s는 OS 이름(예: Linux, Darwin 등)을 반환하고, tr를 통해 소문자로 변환합니다.
OS ?= $(shell uname -s | tr '[:upper:]' '[:lower:]')
# 아키텍처 정보를 반환합니다. (예: amd64, arm64 등)
ARCH := $(shell ./scripts/detect-arch.sh)
LDFLAGS=-ldflags "-linkmode external -extldflags -static"

##build os={os [linux, darwin]} arch={arch [amd64, arm64]}: build application
.PHONY: build
build: os ?= $(OS)
build: arch ?= $(ARCH)
build:
build:
	@echo "[build] Building $(mod) for $(os)/$(arch)"
ifeq ($(os), linux)
	GOOS=$(os) GOARCH=$(arch) go build $(LDFLAGS) -o build/api-$(os)-$(arch) ./server/main.go
else
	GOOS=$(os) GOARCH=$(arch) go build -o build/api-$(os)-$(arch) ./server/main.go
endif

##build-docker tag={tag [v1.0.0]}: build docker image
.PHONY: build-docker
build-docker: tag ?= "latest"
build-docker:
	@echo "[build-docker] Build docker image"
	@echo " *tag: $(tag)"
	docker build --tag "api:$(tag)" .
	mkdir -p .docker
	docker save -o ./.docker/api-$(tag).tar "api:$(tag)"

##clean: clean application
.PHONY: clean
clean:
	@echo "[clean] Cleaning build directory"
	rm -rf build/*
	rm -rf .docker/*

##run: run application
.PHONY: run
run:
	@echo "[run] running application"
	go run ./server/main.go

##deploy tag={tag [v1.0.0]}: deployment blue-green
.PHONY: deploy
deploy: tag ?= "latest" 
deploy:
	@echo "[deploy] Deployment blue-green"
	./scripts/deploy.sh $(tag)
