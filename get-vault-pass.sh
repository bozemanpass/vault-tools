#!/bin/bash

source `dirname $0`/vault_env.sh

# NOOP if we already have a live token
`dirname $0`/login-to-vault.sh

HOST=$1
APPNAME=$2
PW_KEY=$3
FORCE=$4

HOST_KEY=$(echo $HOST | sed 's/\./_/g')

if [ -z "$HOST_KEY" ] || [ -z "$PW_KEY" ] || [ -z "$APPNAME" ]; then
    echo "$0 hostname app key [force]"
    exit
fi

KEY_PATH="secret/${APPNAME}/${HOST_KEY}/${PW_KEY}"

RAND=$(echo `uuidgen``uuidgen` | sed -s 's/-//g')
if [ "$FORCE" == "force" ]; then
    $VAULT_BIN kv put --format=json "${KEY_PATH}" value=${RAND} 1>/dev/null 2>/dev/null
else
    $VAULT_BIN kv put -cas=0 --format=json "${KEY_PATH}" value=${RAND} 1>/dev/null 2>/dev/null
fi

RET=$($VAULT_BIN kv get --format=json "${KEY_PATH}" 2>/dev/null | jq -r '.data.data.value')

echo $RET

if [ -z "$RET" ]; then
    exit 1
else
    exit 0
fi
