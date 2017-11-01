#!/bin/bash
#
# Exécute le container docker dgricci/golang
#
# Constantes :
VERSION="0.12.0"
# Variables globales :
#readonly -A commands=(
#[go]=""
#[godoc]=""
#[gofmt]=""
#[glide]=""
#[golint]=""
#[dep]=""
#)
#
proxyEnv=""
theShell="$(basename $0 | sed -e 's/\.sh$//')"
dockerCmd="docker run -e USER_ID=${UID} -e USER_NAME=${USER} --name=\"go$$\" -v${GOPATH}:/go"
dockerSpecialOpts="--rm=true"
dockerImg="dgricci/golang"
cmdToExec="$theShell"
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
# Process argument
#
processArg () {
    arg="$1"
    [ "${theShell}" = "godoc" ] && {
        [ $(echo "$arg" | grep -c -e '^-http=') -eq 1 ] && {
            dockerSpecialOpts="--detach=true"
            # start doc server background and bound port to host !
            local port="$(echo ${arg} | sed -e 's/^-http=[^:]*:\([0-9]*\)/\1/')"
            dockerSpecialOpts="${dockerSpecialOpts} --publish=${port}:${port}"
        }
    }
    cmdToExec="${cmdToExec} $arg"
}
#
# main
#
[ -z "${GOPATH}" ] && {
    echoerr 2 "ERR: Missing environment variable GOPATH"
}
# remove the GOPATH prefix ...
w="${PWD##${GOPATH}}"
[ "${PWD}" = "${w}" ] && {
    echoerr 3 "ERR: The current directory is not a sub-directory of ${GOPATH}"
}
[ ! -z "${http_proxy}" ] && {
    dockerCmd="${dockerCmd} -e http_proxy=${http_proxy}"
}
[ ! -z "${https_proxy}" ] && {
    dockerCmd="${dockerCmd} -e https_proxy=${https_proxy}"
}
[ "${theShell}" = "glide" -o "${theSell}" = "dep" ] && {
    dockerCmd="${dockerCmd} -it"
}
dockerCmd="${dockerCmd} -w/go${w}"
while [ $# -gt 0 ]; do
    # protect back argument containing IFS characters ...
    arg="$1"
    [ $(echo -n ";$arg;" | tr "$IFS" "_") != ";$arg;" ] && {
        arg="\"$arg\""
    }
    if [ -n "${noMoreOptions}" ] ; then
        processArg "$arg"
    else
        case $arg in
        --help|-h)
            [ -z "${noMoreOptions}" ] && {
                run -1 "${dockerCmd} ${dockerSpecialOpts} ${dockerImg} ${cmdToExec} --help"
                usage 0
            }
            processArg "$arg"
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
            processArg "$arg"
            ;;
        esac
    fi
    shift
done

run 100 "${dockerCmd} ${dockerSpecialOpts} ${dockerImg} ${cmdToExec}"

exit 0

