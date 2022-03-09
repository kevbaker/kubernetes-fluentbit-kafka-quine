#!/usr/bin/env bash

## WARNING: This script does not work yet. Use `Setup` section of README to manually setup 
echo ""
echo ""
echo "--------------------------------------------------------------------------------------------"
read -p  "WARNING: This script does not work yet. Use 'Setup' section of README to manually setup " -n1 -s
echo "\n--------------------------------------------------------------------------------------------"
echo ""
echo ""
exit 1



MINIKUBE_PROFILE=minikube


### Namespace
kubectl create namespace logging

# Create Minikube Cluster
#minikube start  -p $MINIKUBE_PROFILE --memory 8192 --cpus 4 --driver=hyperkit

# List minikube cluster profiles
minikube profile list



### FluentBit setup

# comment: https://github.com/fluent/fluent-bit-kubernetes-logging​
# comment: skip RBAC resources creation for minikube (RBAC is for real cluster, not minikube)
kubectl -n logging create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/fluent-bit-service-account.yaml
kubectl -n logging create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/output/kafka/fluent-bit-configmap.yaml
kubectl -n logging create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/output/kafka/fluent-bit-ds.yaml

### Kafka setup
# comment: https://strimzi.io/quickstarts/
kubectl -n logging create -f 'https://strimzi.io/install/latest?namespace=logging'
kubectl -n logging apply -f https://strimzi.io/examples/latest/kafka/kafka-persistent-single.yaml
kubectl -n logging wait kafka/my-cluster --for=condition=Ready --timeout=300s ​
# Find the name of Kafka service on minikube (hint: my-cluster-kafka-bootstrap)
kubectl -n logging get svc


### FluentBit configuration
#### Edit FluentBit configmap (set correct Kafka adddress)
read -p  "Set output-kafka.conf value to 'Brokers=my-cluster-kafka-bootstrap:9092'\n Press any key to continue:" -n1 -s
kubectl -n logging edit configmap fluent-bit-config

#### Restart fluent-bit daemon set
kubectl -n logging rollout restart ds/fluent-bit

#### Find the topic name which FluentBit will use for sending data
read -p "Find the topic name which FluentBit will use for sending data" -n1 -s
kubectl -n logging get pods -l k8s-app=fluent-bit-logging --no-headers -o custom-columns=NAME:metadata.name | xargs kubectl -n logging logs | grep output:kafka

### Kafka: receive messages for topic
#Topic: `ops.kube-logs-fluentbit.stream.json.001`
#The output will show the contents of minikube node logs by default (current fluentbit config consumes this logs and sends to Kafka topic)
kubectl -n logging run kafka-consumer -ti --image=quay.io/strimzi/kafka:0.27.1-kafka-3.0.0 --rm=true --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --topic ops.kube-logs-fluentbit.stream.json.001 --from-beginning

