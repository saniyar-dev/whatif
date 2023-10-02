ARCHS = amd64 arm64
COMMONENVVAR=GOOS=$(shell uname -s | tr A-Z a-z)
BUILDENVVAR=CGO_ENABLED=0


LOCAL_REGISTRY=saniyardev
LOCAL_IMAGE=whatif-agent:latest

# RELEASE_REGISTRY is the container registry to push
# into. The default is to push to the staging
# registry, not production(k8s.gcr.io).
RELEASE_REGISTRY?=saniyardev
RELEASE_VERSION?=v$(shell date +%Y%m%d)-$(shell git describe --tags --match "v*")
RELEASE_IMAGE:=whatif-agent:$(RELEASE_VERSION)

# VERSION is the scheduler's version
#
# The RELEASE_VERSION variable can have one of two formats:
# v20201009-v0.18.800-46-g939c1c0 - automated build for a commit(not a tag) and also a local build
# v20200521-v0.18.800             - automated build for a tag
VERSION=$(shell echo $(RELEASE_VERSION) | awk -F - '{print $$2}')

.PHONY: all
all: build

.PHONY: build
build: build-scheduler

.PHONY: build.amd64
build.amd64: build-scheduler.amd64

.PHONY: build.arm64v8
build.arm64v8: build-scheduler.arm64v8

.PHONY: build-scheduler
build-scheduler:
	$(COMMONENVVAR) $(BUILDENVVAR) go build -ldflags '-X k8s.io/component-base/version.gitVersion=$(VERSION) -w' -o bin/kube-scheduler cmd/scheduler/main.go

.PHONY: build-scheduler.amd64
build-scheduler.amd64:
	$(COMMONENVVAR) $(BUILDENVVAR) GOARCH=amd64 go build -ldflags '-X k8s.io/component-base/version.gitVersion=$(VERSION) -w' -o bin/kube-scheduler cmd/scheduler/main.go

.PHONY: build-scheduler.arm64v8
build-scheduler.arm64v8:
	GOOS=linux $(BUILDENVVAR) GOARCH=arm64 go build -ldflags '-X k8s.io/component-base/version.gitVersion=$(VERSION) -w' -o bin/kube-scheduler cmd/scheduler/main.go

.PHONY: local-image
local-image: clean
	docker build -f ./build/scheduler/Dockerfile --build-arg ARCH="amd64" --build-arg RELEASE_VERSION="$(RELEASE_VERSION)" -t $(LOCAL_REGISTRY)/$(LOCAL_IMAGE) .

.PHONY: release-image.amd64
release-image.amd64: clean
	docker build -f ./build/scheduler/Dockerfile --build-arg ARCH="amd64" --build-arg RELEASE_VERSION="$(RELEASE_VERSION)" -t $(RELEASE_REGISTRY)/$(RELEASE_IMAGE)-amd64 .

.PHONY: release-image.arm64v8
release-image.arm64v8: clean
	docker build -f ./build/scheduler/Dockerfile --build-arg ARCH="arm64v8" --build-arg RELEASE_VERSION="$(RELEASE_VERSION)" -t $(RELEASE_REGISTRY)/$(RELEASE_IMAGE)-arm64 .

.PHONY: push-release-images
push-release-images: release-image.amd64 release-image.arm64v8
	gcloud auth configure-docker
	for arch in $(ARCHS); do \
		docker push $(RELEASE_REGISTRY)/$(RELEASE_IMAGE)-$${arch} ;\
	done
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create $(RELEASE_REGISTRY)/$(RELEASE_IMAGE) $(addprefix --amend $(RELEASE_REGISTRY)/$(RELEASE_IMAGE)-, $(ARCHS))
	for arch in $(ARCHS); do \
		DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate --arch $${arch} $(RELEASE_REGISTRY)/$(RELEASE_IMAGE) $(RELEASE_REGISTRY)/$(RELEASE_IMAGE)-$${arch} ;\
	done
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push $(RELEASE_REGISTRY)/$(RELEASE_IMAGE) ;\

.PHONY: update-vendor
update-vendor:
	hack/update-vendor.sh

.PHONY: unit-test
unit-test:
	hack/unit-test.sh

.PHONY: install-envtest
install-envtest:
	hack/install-envtest.sh

.PHONY: integration-test
integration-test: install-envtest
	hack/integration-test.sh

.PHONY: verify
verify:
	hack/verify-gofmt.sh
	hack/verify-crdgen.sh
	hack/verify-structured-logging.sh

.PHONY: clean
clean:
	rm -rf ./bin
