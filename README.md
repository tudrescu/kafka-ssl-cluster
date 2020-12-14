
# Kafka SSL Cluster

## SSL Certificates

create SSL Certificates prior to starting the cluster, see the [`README.md`](certificates/README.md).

## Components

- 1 Zookeeper
- 4 Brokers
- AKHQ
- CMAK
- Kafka Client
- kafkacat

Brokers are configured with two listeners, both using SSL.
