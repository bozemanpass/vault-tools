#!/bin/bash

export VAULT_ADDR=${TERRA_ADDR}
export VAULT_ROLE=${TERRA_VAULT_ROLE}
export VAULT_MY_HOST=${TERRA_MY_HOST:-`hostnamectl --static`}
