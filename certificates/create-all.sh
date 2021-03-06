#!/bin/bash

BASE=$(dirname "$0")
cd ${BASE}

./create-ca.sh
[ $? -eq 1 ] && echo "ERROR: unable to create CA root certificate" && exit

./create-intermediate.sh
[ $? -eq 1 ] && echo "ERROR: unable to create intermediate certificate" && exit

./create-certs.sh

./create-keystore.sh
[ $? -eq 1 ] && echo "ERROR: unable to create keystores" && exit
