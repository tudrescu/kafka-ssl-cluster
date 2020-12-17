
# Kafka SSL Cluster

Kafka Cluster using [Docker Compose](cluster/docker-compose.yml) with SSL enabled. A [monitoring](monitoring/docker-compose.yml) Stack using Grafana/Prometheus is also provided.

## SSL Certificates

Prior to starting the Cluster, create the required SSL Certificates (self-signed), see the [`certificates/README.md`](certificates/README.md).

## Components

The following components are provided by the [cluster/docker-compose.yml](cluster/docker-compose.yml).

- 1x Zookeeper
- 4x Brokers
- 1x AKHQ
- 1x CMAK
- 1x Kafka Client (jumphost)
- 1x kafkacat

Brokers are configured with two listeners (INTERNAL/EXTERNAL), both using SSL and clients are required to authenticate using a valid certificate.

## Usage

- change to the [cluster](cluster) directory and start main stack

  ```bash
  cd cluster
  docker-compose up -d
  ```

  The following hostnames and ports can be used _within_ the network / on the host network in order to connect to the components:

  | Component          | docker hostname | internal docker port(s)           | exposed port |
  |--------------------|-----------------|-----------------------------------|--------------|
  | Zookeeper          | zookeeper       | 2181                              |              |
  | Kafka Broker 1     | broker-1        | 9092 (internal), 9093 (external)  | 19093        |
  | Kafka Broker 2     | broker-2        | 9092 (internal), 9093 (external)  | 29093        |
  | Kafka Broker 3     | broker-2        | 9092 (internal), 9093 (external)  | 39093        |
  | Kafka Broker 4     | broker-4        | 9092 (internal), 9093 (external)  | 49093        |
  | CMAK               | kafka-manager   | 9000                              | 9000         |
  | AKHQ               | akhq            | 8080                              | 9080         |
  | Kafka Client       | jumphost        |                                   |              |
  | kafkacat           | kafkacat        |                                   |              |

- helper scripts for common administrative tasks are available [cluster/jumphost](cluster/jumphost) in the `jumphost` (/opt/bin) and `kakfacat` containers respectively. Log into the containers using
  
  ```bash
  docker-compose exec jumphost bash
  ```

  and call the scripts with the desired parameters.

- to activate the monitoring stack, change to the [monitoring](monitoring) directory and start the monitoring stack (optional).

  ```bash
  cd cluster
  docker-compose up -d
  ```

  The monitoring stack includes Prometheus and Grafana. Grafana is exposed on the docker host under [http://localhost:3000](http://localhost:3000).
  
  | Component          | docker hostname | internal docker port(s)           | exposed port |
  |--------------------|-----------------|-----------------------------------|--------------|
  | Prometheus         | prometheus      | 2181                              |              |
  | Grafana            | grafana         | 3000                              | 3000         |

  The brokers are instrumented by default using the [prometheus/jmx-exporter](https://github.com/prometheus/jmx_exporter) agent and with the [jolokia](https://jolokia.org/agent.html) agent. Jolokia exposes the JMX metrics as HTTP endpoint on the docker host on ports 17072, 27072, 37072, 47072 (one for each broker). See the [cluster/bin/restart](cluster/bin/restart) script for an example of using the Jolokia endpoint.

- tear down

   ```bash
   docker-compose down -v
   ```

  in the [cluster](cluster) and [monitoring](monitoring) directories.
