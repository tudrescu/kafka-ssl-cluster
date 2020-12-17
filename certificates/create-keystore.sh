#!/bin/bash

BASE=$(dirname "$0")

cd ${BASE}

. ./env.sh

B_PW=${BROKER_PASSWORD}

for i in ${MACHINES[@]}; do

  key=${i}.key
  req=${i}.req
  crt=${i}.crt
  cnf=${i}.cnf
  keystore=${i}.keystore.jks

#  cat ${CERTS}/intermediate.crt ${CERTS}/ca.crt > ${CERTS}/chain.pem
#  openssl pkcs12 -export -in ${CERTS}/${crt} -inkey ${CERTS}/${key} -passin pass:$B_PW -chain -CAfile ${CERTS}/chain.pem -name $i -out ${CERTS}/$i.p12 -passout pass:$B_PW

  # remove keystore
  rm -f ${CERTS}/${i}.keystore.jks

  # import certficate
  keytool -importkeystore \
    -srckeystore ${CERTS}/${i}.p12 \
    -srcstorepass $B_PW \
    -srcstoretype pkcs12 \
    -destkeystore ${CERTS}/${i}.keystore.jks \
    -deststorepass $B_PW \
    -deststoretype pkcs12

done

# Creating truststore
rm -f ${CERTS}/kafka.server.truststore.jks

keytool -keystore ${CERTS}/kafka.server.truststore.jks \
  -alias ca-root \
  -import -file ${CERTS}/ca.crt \
  -storepass $B_PW \
  -noprompt

keytool -keystore ${CERTS}/kafka.server.truststore.jks \
  -alias intermediate \
  -import -file ${CERTS}/intermediate.crt \
  -storepass $B_PW \
  -noprompt

# save keys into file
if [ ! -f ${CERTS}/.key ]; then
  echo ${B_PW} > ${CERTS}/kafka.key
fi

# create ca.pem for kafkacat
cat ${CERTS}/intermediate.crt ${CERTS}/ca.crt > ${CERTS}/ca.pem




