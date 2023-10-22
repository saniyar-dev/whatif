ARG ARCH
FROM hub.hamdocker.ir/library/golang:1.17.11

WORKDIR /go/src/github.com/saniyar-dev/whatif
COPY . .
ARG ARCH
ARG RELEASE_VERSION
RUN RELEASE_VERSION=${RELEASE_VERSION} make build-scheduler.$ARCH

FROM hub.hamdocker.ir/$ARCH/alpine:3.16

COPY --from=0 /go/src/github.com/saniyar-dev/whatif/bin/kube-scheduler /bin/kube-scheduler

WORKDIR /bin
CMD ["kube-scheduler"]
