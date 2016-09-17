## Dockerfile for golang environment
FROM dgricci/build-jessie:0.0.1
MAINTAINER Didier Richard <didier.richard@ign.fr>

RUN \
    apt-get -qy update && \
    rm -rf /var/lib/apt/lists/*

## different versions - use argument when defined otherwise use defaults
ARG GOLANG_VERSION
ENV GOLANG_VERSION ${GOLANG_VERSION:-1.6.3}
ARG GOLANG_DOWNLOAD_URL
ENV GOLANG_DOWNLOAD_URL ${GOLANG_DOWNLOAD_URL:-https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz}
ARG GOLANG_DOWNLOAD_SHA256
ENV GOLANG_DOWNLOAD_SHA256 ${GOLANG_DOWNLOAD_SHA256:-cdde5e08530c0579255d6153b08fdb3b8e47caabbe717bc7bcd7561275a87aeb}
ENV GOPATH /go
ENV GOBIN  $GOPATH/bin
ENV PATH $GOBIN:/usr/local/go/bin:$PATH

## install golang, then the sudo version in ... golang !
## one could have download the source code and compile to go source !-)
RUN \
    curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz && \
    echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - && \
    tar -C /usr/local -xzf golang.tar.gz && \
    rm golang.tar.gz && \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    mkdir -p "$GOPATH/src" "$GOPATH/bin" "$GOPATH/pkg" && chmod -R 777 "$GOPATH"

WORKDIR $GOPATH

# Cf. https://github.com/docker-library/golang/blob/master/1.6/wheezy/Dockerfile
COPY go-wrapper /usr/local/go/bin/

# default command : prints go version and exits
CMD ["go", "version"]

