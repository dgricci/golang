% Environnement GoLang
% Didier Richard
% rév. 0.0.1 du 01/08/2016
% rév. 0.0.2 du 10/09/2016
% rév. 0.0.3 du 17/09/2016
% rév. 0.0.4 du 20/10/2016
% rév. 0.0.5 du 19/12/2016
% rév. 0.0.6 du 19/02/2017
% rév. 0.0.7 du 11/03/2017

---

# Building #

```bash
$ docker build -t dgricci/golang:$(< VERSION) .
$ docker tag dgricci/golang:$(< VERSION) dgricci/golang:latest
```

## Behind a proxy (e.g. 10.0.4.2:3128) ##

```bash
$ docker build \
    --build-arg http_proxy=http://10.0.4.2:3128/ \
    --build-arg https_proxy=http://10.0.4.2:3128/ \
    -t dgricci/golang:$(< VERSION) .
$ docker tag dgricci/golang:$(< VERSION) dgricci/golang:latest
```

## Build command with arguments default values ##

```bash
$ docker build \
    --build-arg GOLANG_VERSION=1.8 \
    --build-arg GOLANG_DOWNLOAD_URL=https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz \
    --build-arg GOLANG_DOWNLOAD_SHA256=53ab94104ee3923e228a2cb2116e5e462ad3ebaeea06ff04463479d7f12d27ca \
    -t dgricci/golang:$(< VERSION) .
$ docker tag dgricci/golang:$(< VERSION) dgricci/golang:latest
```

# Use #

See `dgricci/jessie` README for handling permissions with dockers volumes.

```bash
$ docker run -it --rm dgricci/golang
go version go1.8 linux/amd64
```

## An example ##

### run ###

```bash
$ mkdir -p test test/{bin,pkg,src} test/src/hello
$ cd test
$ cat > ./src/hello/world.go <<- EOF
package main

import "fmt"

func main() {
    fmt.Println("hello world")
}
EOF
$ tree .
.
├── bin
├── pkg
└── src
    └── hello
        └── world.go

4 directories, 1 files
$ docker run -i --rm -v `pwd`:/go -w/go/src/hello -e USER_ID=`id -u` dgricci/golang go run world.go
hello world
```

### build ###

Let's suppose that the env variable GOPATH points at the current directory :

```bash
$ pwd
/home/dgricci/test
$ echo $GOPATH
/home/dgricci/test
$ cd src/hello
$ docker run --rm -v${GOPATH}:/go -w/go${PWD##${GOPATH}} -e USER_ID=`id -u` -e USER_NAME=`whoami` dgricci/golang go build world.go
$ ./world
hello world
```

## Tests ##

Just launch `base-jessie.bats` (once `bats`[^bats] is installed on your
system) :

```bash
$ ./golang.bats --tap
1..3
ok 1 check golang ok
ok 2 run hello world
ok 3 build hello world
```

## A shell to hide container's usage ##

```bash
#!/bin/bash
#
# Exécute le container docker dgricci/golang
#
# Constantes :
VERSION="0.9.0"
# Variables globales :
readonly -A commands=(
[go]=""
[godoc]=""
[gofmt]=""
)
#
theShell="$(basename $0)"
theShell="${theShell%.sh}"
#
unset show
unset noMoreOptions
#
# Exécute ou affiche une commande
# $1 : code de sortie en erreur
# $2 : commande à exécuter
run () {
    local code=$1
    local cmd=$2
    if [ -n "${show}" ] ; then
        echo "cmd: ${cmd}"
    else
        eval ${cmd}
    fi
    # go|godoc|gofmt --help returns 2 ...
    [ ${code} -ge 0 -a $? -ne 0 ] && {
        echo "Oops #################"
        exit ${code#-} #absolute value of code
    }
    [ ${code} -ge 0 ] && {
        return 0
    }
}
#
# Affichage d'erreur
# $1 : code de sortie
# $@ : message
echoerr () {
    local code=$1
    shift
    echo "$@" 1>&2
    usage ${code}
}
#
# Usage du shell :
# $1 : code de sortie
usage () {
    cat >&2 <<EOF
usage: `basename $0` [--help -h] | [--show|-s] commandAndArguments

    --help, -h          : prints this help and exits
    --show, -s          : do not execute $theShell, just show the command to be executed

    commandAndArguments : arguments and/or options to be handed over to ${theShell}.
                          The directory where this script is lauched is a
                          sub-directory of GOPATH.

    The GOPATH environment variable must be set to the directory containing
    the golang sources, binaries and packages (aka golang projects !)
EOF
    exit $1
}
#
# main
#
[ -z "${GOPATH}" ] && {
    echoerr 2 "Missing environment variable GOPATH"
}
# remove the GOPATH prefix ...
w="${PWD##${GOPATH}}"
[ "${PWD}" = "${w}" ] && {
    echoerr 3 "The current directory is not a sub-directory of ${GOPATH}"
}
cmdToExec="docker run -e USER_ID=${UID} -e USER_NAME=${USER} --name=\"go$$\" --rm=true -v${GOPATH}:/go -w/go${w} dgricci/golang $theShell"
while [ $# -gt 0 ]; do
    # protect back argument containing IFS characters ...
    arg="$1"
    [ $(echo -n ";$arg;" | tr "$IFS" "_") != ";$arg;" ] && {
        arg="\"$arg\""
    }
    if [ -n "${noMoreOptions}" ] ; then
        cmdToExec="${cmdToExec} $arg"
    else
        case $arg in
        --help|-h)
            run -1 "${cmdToExec} --help"
            usage 0
            ;;
        --show|-s)
            show=true
            noMoreOptions=true
            ;;
        --)
            noMoreOptions=true
            ;;
        *)
            [ -z "${noMoreOptions}" ] && {
                noMoreOptions=true
            }
            cmdToExec="${cmdToExec} $arg"
            ;;
        esac
    fi
    shift
done

run 100 "${cmdToExec}"

exit 0
```

__Et voilà !__


_fin du document[^pandoc_gen]_

[^pandoc_gen]: document généré via $ `pandoc -V fontsize=10pt -V geometry:"top=2cm, bottom=2cm, left=1cm, right=1cm" -s -N --toc -o golang.pdf README.md`{.bash}

