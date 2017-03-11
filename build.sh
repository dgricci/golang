#!/bin/bash

## Dockerfile for golang environment

# install
apt-get -qy update
rm -rf /var/lib/apt/lists/*

## install golang, then the sudo version in ... golang !
## one could have download the source code and compile to go source !-)
curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz
echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c -
tar -C /usr/local -xzf golang.tar.gz
rm golang.tar.gz
gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
mkdir -p "$GOPATH/src" "$GOPATH/bin" "$GOPATH/pkg" && chmod -R 777 "$GOPATH"

# uninstall and clean

exit 0

