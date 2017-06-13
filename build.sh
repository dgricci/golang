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
gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
mkdir -p "$GOPATH/src" "$GOPATH/bin" "$GOPATH/pkg" && chmod -R 777 "$GOPATH"

# uninstall and clean

exit 0

