#!/bin/bash

source `dirname $0`/vault_env.sh

# NOOP if we already have a live token
`dirname $0`/login-to-vault.sh

PART=$1
FORCE=$2

rc=0

if [ ! -f "$HOME/.hashivault/cert" ] || [ "$FORCE" == "force" ]; then
    if [ -f "$HOME/.hashivault/cert" ]; then
        mv -f "$HOME/.hashivault/cert" "$HOME/.hashivault/cert.$$"
    fi
    ISSUE_ROLE=`hostnamectl --static | sed 's/\./-/g'`
    $VAULT_BIN write --format=json pki/issue/$ISSUE_ROLE common_name=$VAULT_MY_HOST > $HOME/.hashivault/cert
    rc=$?
    chmod 600 $HOME/.hashivault/cert*
fi

if [ "key" == "$PART" ]; then
    cat "$HOME/.hashivault/cert" | jq -r '.data.private_key'
elif [ "cert" == "$PART" ]; then
    cat "$HOME/.hashivault/cert" | jq -r '.data.certificate'
elif [ "ca" == "$PART" ]; then
    cat "$HOME/.hashivault/cert" | jq -r '.data.issuing_ca'
elif [ "serial" == "$PART" ]; then
    cat "$HOME/.hashivault/cert" | jq -r '.data.serial_number'
fi

exit $rc
