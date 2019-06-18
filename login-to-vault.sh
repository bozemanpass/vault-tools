#!/bin/bash

source `dirname $0`/vault_env.sh

if [ ! -d "$HOME/.hashivault" ]; then
    mkdir $HOME/.hashivault
    chmod 700 $HOME/.hashivault
fi

FORCE="$1"

ok=$?

if [ "$FORCE" != "force" ] && [ -s "$HOME/.vault-token" ] && [ -s "$HOME/.hashivault/.expire" ] && [ -s "$HOME/.hashivault/last-login" ]; then
    now=`date "+%s"`
    expire=$((`cat "$HOME/.hashivault/.expire"` - 600))
    if [ $now -lt $expire ]; then
        # nothing needed
        exit 0
    fi
fi

if [ ! -s "$HOME/.hashivault/first-login" ]; then
    $VAULT_BIN write auth/aws/login --format=json \
                role=$VAULT_ROLE \
                pkcs7="$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/pkcs7)" > $HOME/.hashivault/.tmp-login.$$
    ok=$?
    if [ $ok -eq 0 ]; then
        cp -f $HOME/.hashivault/.tmp-login.$$ $HOME/.hashivault/first-login
        cp -f $HOME/.hashivault/first-login $HOME/.hashivault/last-login
        cp -f $HOME/.hashivault/first-login $HOME/.hashivault/.first-login
        dur=`cat $HOME/.hashivault/last-login | jq -r '.auth.lease_duration'`
        expire=`date -d "$dur seconds" "+%s"`
        echo "$expire" > $HOME/.hashivault/.expire
    fi
else
    $VAULT_BIN write auth/aws/login --format=json \
                role=$VAULT_ROLE \
                pkcs7="$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/pkcs7)" \
                nonce="$(cat $HOME/.hashivault/first-login | jq -r '.auth.metadata.nonce')" > $HOME/.hashivault/.tmp-login.$$
    ok=$?
    if [ $ok -eq 0 ]; then
        cp -f $HOME/.hashivault/.tmp-login.$$ $HOME/.hashivault/last-login
        dur=`cat $HOME/.hashivault/last-login | jq -r '.auth.lease_duration'`
        expire=`date -d "$dur seconds" "+%s"`
        echo "$expire" > $HOME/.hashivault/.expire
    fi
fi

rm -f $HOME/.hashivault/.tmp-login.$$

chmod 600 $HOME/.hashivault/* $HOME/.hashivault/.* 2>/dev/null

if [ $ok -eq 0 ]; then
    cat $HOME/.hashivault/last-login | jq -r '.auth.client_token' > $HOME/.vault-token
fi

if [ -f "$HOME/.vault-token" ]; then
    chmod 600 $HOME/.vault-token
fi

exit $ok
