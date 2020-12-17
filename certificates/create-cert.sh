#!/bin/bash

if [ $# -lt 1 ]; then
  echo "usage: $0 hostname"
  exit
fi

BASE=$(dirname "$0")

cd ${BASE}

. ./env.sh

HOSTNAME=$1
shift

CA_PW=${CA_PASSWORD}
IN_PW=${INTERMEDIATE_PASSWORD}
B_PW=${BROKER_PASSWORD}

DOMAIN="local.dev"

#
# Subject should be adjusted for your location, with the CN record being the hostname.
#
COUNTRY=DE
STATE=BW
CITY=KARLSRUHE
ORG=COMPANY
UNIT=KAFKA
i=${HOSTNAME}

#SUBJECT="/C=${COUNTRY}/ST=${STATE}/L=${CITY}/O=${ORG}/OU=${UNIT}/CN=${i}"
SUBJECT="/CN=${i}"

key=${i}.key
req=${i}.req
crt=${i}.crt
cnf=${i}.cnf
keystore=${i}.keystore.jks

printf "\ngenerating key, csr, crt, and p12 file for $i\n\n"

printf "generate key\n============\n\n"
openssl genrsa \
	-aes128 \
	-passout pass:${B_PW} \
	-out ${CERTS}/${key} 3072
[ $? -eq 1 ] && echo "ERROR: unable to generate key for ${i}." && exit

printf "\n\nverify key\n==========\n\n"
openssl rsa \
	-check \
	-in ${CERTS}/${key} \
	-passin pass:${B_PW} 
[ $? -eq 1 ] && echo "ERROR: unable to verify key for ${i}." && exit

printf "\n\ngenerate csr\n==========\n\n"
openssl req \
	-new \
	-sha256 \
	-key ${CERTS}/${key} \
	-passin pass:${B_PW} \
	-out ${CERTS}/${req} \
	-subj "${SUBJECT}" \
	-reqexts SAN \
	-config <(cat ./openssl.cnf <(printf "\n[SAN]\nsubjectAltName=DNS:${i}\nextendedKeyUsage=serverAuth,clientAuth"))
[ $? -eq 1 ] && echo "ERROR: unable to generate csr for ${i}." && exit

printf "\n[v3_ca]\nsubjectAltName=DNS:${i}, DNS:${i}.${DOMAIN}\nextendedKeyUsage=serverAuth,clientAuth" > ${CERTS}/${cnf}

printf "\ncsr\n===\n\n"
openssl req \
	-in ${CERTS}/${req} \
	-text \
	-noout
[ $? -eq 1 ] && echo "ERROR: unable to print certificate for ${i}." && exit


## Sign

printf "\n\nsign csr\n========\n\n"

#
# sign the certificate request and extensions file
#
openssl x509 \
	-req \
	-CA ${CERTS}/intermediate.crt \
	-CAkey ${CERTS}/intermediate.key \
	-passin pass:$IN_PW \
	-in ${CERTS}/${req} \
	-out ${CERTS}/${crt} \
	-days 365 \
	-CAcreateserial \
	-extfile ${CERTS}/${cnf} \
	-extensions v3_ca 
[ $? -eq 1 ] && echo "ERROR: unable to sign the csr for ${i}." && exit

# create Certificate chain
cat ${CERTS}/intermediate.crt ${CERTS}/ca.crt > ${CERTS}/chain.pem

# verify Certificate chain
openssl verify -CAfile ${CERTS}/chain.pem ${CERTS}/${crt}
[ $? -eq 1 ] && echo "ERROR: unable to verify certificate for ${i}." && exit

printf "\ncertificate\n===========\n\n"
openssl x509 \
	-in ${CERTS}/${crt} \
	-text \
	-noout
[ $? -eq 1 ] && echo "ERROR: unable to print certificate for ${i}." && exit

# combine key and certificate into a pkcs12 file
openssl pkcs12 \
	-export \
	-in ${CERTS}/${crt} \
	-inkey ${CERTS}/${key} \
	-passin pass:$B_PW \
	-chain \
	-CAfile ${CERTS}/chain.pem \
	-name $i \
	-out ${CERTS}/$i.p12 \
	-passout pass:$B_PW
[ $? -eq 1 ] && echo "ERROR: unable to create pkcs12 file for ${i}." && exit


printf "\nFinished generating certificate for: ${i}\n===========\n\n"