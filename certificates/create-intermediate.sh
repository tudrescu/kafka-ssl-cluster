#!/bin/bash

BASE=$(dirname "$0")

cd ${BASE}

. ./env.sh

CA_PW=${CA_PASSWORD}
IN_PW=${INTERMEDIATE_PASSWORD}

days_validity="365"

#
# The subject name of your intermediate certificate.
#
subject="/CN=Kafka-intermediate"

key=intermediate.key
req=intermediate.csr
crt=intermediate.crt

echo ""
echo "==============================="
echo "create intermediate certificate"
echo "==============================="
echo ""

printf "\n\ncreated IN key and IN csr\n=========================\n\n"
openssl req \
	-newkey rsa:1024 \
	-sha1 \
	-passout pass:${IN_PW} \
	-keyout ${CERTS}/${key} \
	-out ${CERTS}/${req} \
	-subj ${subject} \
	-extensions ext \
	-config <(cat ./openssl.cnf <(printf "\n[ext]\nbasicConstraints=CA:TRUE"))
[ $? -eq 1 ] && echo "ERROR: unable to create IN key and csr" && exit

printf "\n\nverify IN key\n=============\n\n"
openssl rsa \
	-check \
	-in ${CERTS}/${key} \
	-passin pass:${IN_PW} 
[ $? -eq 1 ] && echo "ERORR: unable to verify IN key" && exit

printf "\n\nverify IN csr\n=============\n\n"
openssl req \
	-text \
	-noout \
	-verify \
	-in ${CERTS}/${req}
[ $? -eq 1 ] && echo "ERROR: unable to verify IN csr" && exit

printf "\n\nsign IN csr\n===========\n\n"
openssl x509 \
	-req \
	-CA ${CERTS}/ca.crt \
	-CAkey ${CERTS}/ca.key \
	-passin pass:${CA_PW} \
	-in ${CERTS}/${req} \
	-sha1 \
	-days "${days_validity}" \
	-out ${CERTS}/${crt} \
	-CAcreateserial \
	-extensions ext \
	-extfile <(cat ./openssl.cnf <(printf "\n[ext]\nbasicConstraints=CA:TRUE"))
[ $? -eq 1 ] && echo "ERROR: unable to sign IN csr" && exit

printf "\n\nverify CS crt\n=============\n\n"
openssl x509 -in ${CERTS}/${crt} -text -noout
[ $? -eq 1 ] && echo "ERROR: unable to verify IN crt" && exit

printf "\n\n"
