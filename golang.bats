#!/usr/bin/env bats

RUNOPTS="-i --rm"
IMG="dgricci/golang:$(< VERSION)"

setup() {
    echo "setting up ..."
    mkdir -p ./test ./test/{src,pkg,bin} ./test/src/hello
    cat > ./test/src/hello/world.go <<- EOF
package main

import "fmt"

func main() {
    fmt.Println("hello world")
}
EOF
}

@test "check golang ok" {
    run bash -c "docker run ${RUNOPTS} ${IMG}"
    [[ ${status} -eq 0 ]]
}

@test "run hello world" {
    local uid="$(id -u)"
    local unm="dgricci"
    local pwd="$(pwd)"
    local cmd="go run world.go ; exit"
    run bash -c "docker run ${RUNOPTS} -v${pwd}/test:/go -w/go/src/hello -e USER_ID=${uid} -e USER_NAME=${unm} ${IMG} ${cmd}"
    [[ ${output} == "hello world" ]]
}

@test "build hello world then launch" {
    local uid="$(id -u)"
    local unm="dgricci"
    local pwd="$(pwd)"
    local cmd="go build world.go ; exit"
    run bash -c "docker run ${RUNOPTS} -v${pwd}/test:/go -w/go/src/hello -e USER_ID=${uid} -e USER_NAME=${unm} ${IMG} ${cmd}"
    [[ ${status} -eq 0 ]]
    run ./test/src/hello/world
    [[ ${output} == "hello world" ]]
}

teardown() {
    echo "tearing down !"
    rm -fr ./test/
}

