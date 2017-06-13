## Dockerfile for golang environment
FROM dgricci/build-jessie:0.0.4
MAINTAINER Didier Richard <didier.richard@ign.fr>

## different versions - use argument when defined otherwise use defaults
ARG GOLANG_VERSION
ENV GOLANG_VERSION ${GOLANG_VERSION:-1.8.3}
ARG GOLANG_DOWNLOAD_URL
ENV GOLANG_DOWNLOAD_URL ${GOLANG_DOWNLOAD_URL:-https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz}
ARG GOLANG_DOWNLOAD_SHA256
ENV GOLANG_DOWNLOAD_SHA256 ${GOLANG_DOWNLOAD_SHA256:-1862f4c3d3907e59b04a757cfda0ea7aa9ef39274af99a784f5be843c80c6772}
ENV GOROOT /usr/local/go
ENV GOPATH /go
ENV GOBIN  $GOPATH/bin
ENV PATH $GOBIN:$GOROOT/bin:$PATH

COPY build.sh /tmp/build.sh

## install golang, then the sudo version in ... golang !
RUN /tmp/build.sh && rm -f /tmp/build.sh

WORKDIR $GOPATH
# Cf. https://github.com/docker-library/golang/blob/master/1.6/wheezy/Dockerfile
COPY go-wrapper $GOROOT/bin/

# default command : prints go version and exits
CMD ["go", "version"]

