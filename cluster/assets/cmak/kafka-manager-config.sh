#!/bin/bash

KAFKA_BOOTSTRAP_SERVERS=${KAFKA_BOOTSTRAP_SERVERS:-broker-1:9092}
KAFKA_CLUSTER_NAME=${KAFKA_CLUSTER_NAME:-prot_cluster}
KAFKA_MANAGER_HOST=${KAFKA_MANAGER_HOST:-kafka-manager:9000}

RETRY_COUNT=20
SLEEP_TIME=5
GET_CLUSTER_INFO_URL="$KAFKA_MANAGER_HOST/clusters/${KAFKA_CLUSTER_NAME}"

CREATE_CLUSTER_COMMAND="curl -s 'http://$KAFKA_MANAGER_HOST/clusters' \
                            -H 'Connection: keep-alive' \
                            -H 'Cache-Control: max-age=0' \
                            -H 'Origin: http://$KAFKA_MANAGER_HOST' \
                            -H 'Content-Type: application/x-www-form-urlencoded' \
                            -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' \
                            -H 'Referer: http://$KAFKA_MANAGER_HOST/addCluster' \
                            -H 'Accept-Encoding: gzip, deflate, br' \
                            --data 'name=${KAFKA_CLUSTER_NAME}&zkHosts=zookeeper%3A2181&kafkaVersion=2.4.0&jmxEnabled=true&jmxUser=&jmxPass&pollConsumers=true&filterConsumers=true&tuning.brokerViewUpdatePeriodSeconds=30&tuning.clusterManagerThreadPoolSize=2&tuning.clusterManagerThreadPoolQueueSize=100&tuning.kafkaCommandThreadPoolSize=2&tuning.kafkaCommandThreadPoolQueueSize=100&tuning.logkafkaCommandThreadPoolSize=2&tuning.logkafkaCommandThreadPoolQueueSize=100&tuning.logkafkaUpdatePeriodSeconds=30&tuning.partitionOffsetCacheTimeoutSecs=5&tuning.brokerViewThreadPoolSize=12&tuning.brokerViewThreadPoolQueueSize=1000&tuning.offsetCacheThreadPoolSize=12&tuning.offsetCacheThreadPoolQueueSize=1000&tuning.kafkaAdminClientThreadPoolSize=12&tuning.kafkaAdminClientThreadPoolQueueSize=1000&tuning.kafkaManagedOffsetMetadataCheckMillis=30000&tuning.kafkaManagedOffsetGroupCacheSize=1000000&tuning.kafkaManagedOffsetGroupExpireDays=7&securityProtocol=SSL&saslMechanism=DEFAULT&jaasConfig=' --compressed"

if [[ -z "${KAFKA_BOOTSTRAP_SERVERS}" ]] || [[ -z "${KAFKA_MANAGER_HOST}" ]] || [[ -z "${KAFKA_CLUSTER_NAME}" ]]; then
  echo "Provide all configuration options"
  exit
else
	echo "Setting up cluster"
	# Wait for KAFKA manager
	# Check whether host is available
	retries=0
	while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' $KAFKA_MANAGER_HOST)" != "200" ]] && [[ $retries -lt $RETRY_COUNT ]]; do
		echo "Connecting to $KAFKA_MANAGER_HOST , attempt #$retries"
		retries=$((retries+1))
		sleep $SLEEP_TIME;
	done
	echo "Connected to the Kafka Manager host"
	# Set up cluster
	address=${KAFKA_BOOTSTRAP_SERVERS}
	name=${KAFKA_CLUSTER_NAME}
	echo "Setting up Cluster $address - $name"
	echo "Checking if the cluster already defined"
	effective_url=${GET_CLUSTER_INFO_URL/cname/$name}
	echo "$effective_url"
	result=$(curl -s $effective_url)
	if [[ $result == *"Unknown cluster"* ]]; then
		echo "Creating cluster $address - $name"
		effective_command=${CREATE_CLUSTER_COMMAND/cname/$name}
		result=$(eval $effective_command)
		echo "Cluster has been created"
	else
		echo "Cluster already exists"
	fi
	
fi