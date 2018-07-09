#!/bin/bash

## Dockerfile for golang environment

# install
apt-get -qy update
rm -rf /var/lib/apt/lists/*

## install golang, then the sudo version in ... golang !
## one could have download the source code and compile to go source !-)
gobinrelease="/tmp/golang.tar.gz"
curl -fsSL "$GOLANG_DOWNLOAD_URL" -o $gobinrelease
echo "$GOLANG_DOWNLOAD_SHA256  $gobinrelease" | sha256sum -c -
tar -C /usr/local -xzf $gobinrelease
rm $gobinrelease

mkdir -p $GOROOT/bin && chmod -R 777 $GOROOT

mkdir -p $GOPATH/{src,bin,pkg} && chmod -R 777 "$GOPATH"
# install dep
go get -u github.com/golang/dep/cmd/dep
mv $GOPATH/bin/dep $GOROOT/bin

# install golint
go get -u github.com/golang/lint/golint
mv $GOPATH/bin/golint $GOROOT/bin/

rm -fr $GOPATH/src/github.com/
rm -fr $GOPATH/src/golang.org/

# uninstall and clean

exit 0

