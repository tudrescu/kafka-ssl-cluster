#!/bin/bash

set -eu

declare -a MACHINES=("root" "broker-1" "broker-2" "broker-3" "broker-4" "jumphost" "kafka-manager" "kafkacat" "akhq")

# location to store certificates
CERTS=../cluster/certs

# password of the root authority certificate
CA_PASSWORD=ca_secret

# password of the intermediate certificate
INTERMEDIATE_PASSWORD=int_secret

# password of the broker certificate and the Java keystore
# keystore password and key password must be the same
BROKER_PASSWORD=dev_cluster_secret

# initialize directory
mkdir -p "${CERTS}"

