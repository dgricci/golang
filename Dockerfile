## Dockerfile for golang environment
FROM dgricci/build-jessie:0.0.4
MAINTAINER Didier Richard <didier.richard@ign.fr>

## different versions - use argument when defined otherwise use defaults
ARG GOLANG_VERSION
ENV GOLANG_VERSION ${GOLANG_VERSION:-1.8}
ARG GOLANG_DOWNLOAD_URL
ENV GOLANG_DOWNLOAD_URL ${GOLANG_DOWNLOAD_URL:-https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz}
ARG GOLANG_DOWNLOAD_SHA256
ENV GOLANG_DOWNLOAD_SHA256 ${GOLANG_DOWNLOAD_SHA256:-53ab94104ee3923e228a2cb2116e5e462ad3ebaeea06ff04463479d7f12d27ca}
ENV GOPATH /go
ENV GOBIN  $GOPATH/bin
ENV PATH $GOBIN:/usr/local/go/bin:$PATH

COPY build.sh /tmp/build.sh

## install golang, then the sudo version in ... golang !
RUN /tmp/build.sh && rm -f /tmp/build.sh

WORKDIR $GOPATH
# Cf. https://github.com/docker-library/golang/blob/master/1.6/wheezy/Dockerfile
COPY go-wrapper /usr/local/go/bin/

# default command : prints go version and exits
CMD ["go", "version"]

