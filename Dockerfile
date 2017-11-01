## Dockerfile for golang environment
FROM dgricci/build-jessie:0.0.4
MAINTAINER Didier Richard <didier.richard@ign.fr>

## different versions - use argument when defined otherwise use defaults
ARG GOLANG_VERSION
ENV GOLANG_VERSION ${GOLANG_VERSION:-1.9.2}
ARG GOLANG_DOWNLOAD_URL
ENV GOLANG_DOWNLOAD_URL ${GOLANG_DOWNLOAD_URL:-https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz}
ARG GOLANG_DOWNLOAD_SHA256
ENV GOLANG_DOWNLOAD_SHA256 ${GOLANG_DOWNLOAD_SHA256:-de874549d9a8d8d8062be05808509c09a88a248e77ec14eb77453530829ac02b}
ARG GLIDE_VERSION
ENV GLIDE_VERSION ${GLIDE_VERSION:-v0.13.0}
ARG GLIDE_DOWNLOAD_URL
ENV GLIDE_DOWNLOAD_URL ${GLIDE_DOWNLOAD_URL:-https://github.com/Masterminds/glide/releases/download/$GLIDE_VERSION/glide-$GLIDE_VERSION-linux-amd64.tar.gz}
ENV GOROOT /usr/local/go
ENV GOPATH /go
ENV GOBIN  $GOPATH/bin
ENV PATH $GOBIN:$GOROOT/bin:$PATH

COPY build.sh /tmp/build.sh

## install golang, then the sudo version in ... golang !
RUN /tmp/build.sh && rm -f /tmp/build.sh

WORKDIR $GOPATH
# Cf. https://github.com/docker-library/golang/blob/master/1.8/Dockerfile
COPY go-wrapper $GOROOT/bin/

# default command : prints go version and exits
CMD ["go", "version"]

