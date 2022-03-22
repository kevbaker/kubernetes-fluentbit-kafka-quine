

<h1 align="center">Kubernetes / Quine Project</h1>

---
<p align="center" width="100%">

<img src="extra/images/Kubernetes_Logo.png" height="50">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

<img src="extra/images/Fluentbit_Logo.png" height="50">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

<img src="extra/images/Kafka_Logo.png" height="40">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

<img src="extra/images/Quine_Logo.svg" height="40">
</p>

---


## Overview

This is a project to demonstrate Kubernetes Cluster logging integrated with Quine.


## Primary Use Case

### Intent

Discover the series of related events that lead to a Kubernetes autoscaling operation using [thatDot Quine](https://quine.io) connected to streaming log data. 

### Questions

* Is the scale operation due to a need for optimization?
* Is the scale operation due to a bug such as a memory leak?
* Is the scale operation due to high traffic on popular container service?
* Is the scale operation due to high traffic from a possible unusual hacker-like activity?
* Should the operations leading to the autoscaling be shut down?


## Project Stack

- **Kind** - A tool for running local Kubernetes clusters.
- **Kubernetes** - Container Orchestration System.
- **Fluentbit** - A scalable logging and metrics processor and forwarder.
- **Kafka** - A platform for handling real-time data feeds used to stream logs messages.
- **Quine** - Streaming graph system that connects to the log data streams and builds high-volume data into a stateful graph for analysis.




## Outcomes

Below are the outcomes from the project.

### Sample Data

Below is sample data used to form the Quine "standing query".


#### Sample Data File

 Here is a [:package: link to a compressed sample data file](extra/data/kafka-topic-output.txt.gz) exported from an active Kafka log stream.

#### Data File Log Samples

Here are sample log file snippets exported from an active Kafka log stream.



##### horizontalpodautoscaling :pushpin: 

```json
{
  "@timestamp": 1646239194.285511,
  "log": "2022-03-02T16:39:18.641434142Z stdout F {\"@timestamp\":1646239156.170701,\"log\":\"2022-03-02T16:39:09.141771216Z stdout F {\\\"@timestamp\\\":1646239049.969076,\\\"log\\\":\\\"2022-03-02T15:40:09.606002004Z stderr F I0302 15:40:09.605799       1 controllermanager.go:574] Started \\\\\\\"horizontalpodautoscaling\\\\\\\"\\\"}\"}"
}
```

```json
{"@timestamp":1646644110.080202,"log":"2022-03-07T09:08:30.051273291Z stderr F 2022-03-07 09:08:30.051054 W | etcdserver: read-only range request \"key:\\\"/registry/horizontalpodautoscalers/\\\" range_end:\\\"/registry/horizontalpodautoscalers0\\\" count_only:true \" with result \"range_response_count:0 size:8\" took too long (158.268848ms) to execute"}
```





### Quine Findings

*Quine configurations, outputs and findings here.*



## Project Setup

This project was based on projects samples from the "References" below. These were exxtended with Fluentbit, Kafka and Quine. Details are below.


### Step: Setup Example Server

This project is setup on a single-node Kubernetes cluster for the complete stack hosted on Ubuntu. This is for demonstration purposes only, in production this would be setup in a multi-Node Kubernetes cluster.

This can be setup on any cloud-based VM or locally in a *nix compatible OS. 

*For the example provisioning code to work below an `apt`-based package manager is needed. This can easily be ported over to whatever package manager is being used.*


### Setup Kubernetes with Kind

Kind is used to manage the single-node cluser in this project.

* [Install Kind from binaries on Linux](https://kind.sigs.k8s.io/docs/user/quick-start/#installing-from-source) - Once complete you will have a working version of Kind running on your server. This can be used to manage a sample cluster on a single-node instance of Kubernetes.
  
  ```bash
  COPY
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
  chmod +x ./kind
  mv ./kind /some-dir-in-your-PATH/kind
  ```

* Create a sample Kubernetes Cluster using Kind
  ```bash
  kind create cluster --name hpa --image kindest/node:v1.18.4
  ```

* Setup Logging namespace in Kubernetes. This is used by a number of containers.

  ```bash
  kubectl create namespace logging
  ```


### Setup Kubernetes Horizontal Autoscale

Follow this guide:

* [YouTube: Kubernetes pod autoscaling for beginners with kind](https://www.youtube.com/watch?v=FfDI08sgrYY) - Uses `Kind`.


### Setup Fluentbit

This setup is based on this [Fluentbit Guide](https://github.com/fluent/fluent-bit-kubernetes-logging)


```bash
kubectl -n logging create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/fluent-bit-service-account.yaml
kubectl -n logging create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/output/kafka/fluent-bit-configmap.yaml
kubectl -n logging create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/output/kafka/fluent-bit-ds.yaml
```


### Setup Kafka

The Kafka setup is based on the [Strimzi project](https://strimzi.io/quickstarts), "Kafka on Kubernetes in a few minutes".

```bash
kubectl -n logging create -f 'https://strimzi.io/install/latest?namespace=logging'
kubectl -n logging apply -f https://strimzi.io/examples/latest/kafka/kafka-persistent-single.yaml
kubectl -n logging wait kafka/my-cluster --for=condition=Ready --timeout=300s 
```

#### Get Kafka Service URL

Find the Kafka Service name and port on Kubernetes and store for later use.

*Hint: something like "my-cluster-kafka-bootstrap:9092", Kafka generally runs on port "9092".*

`kubectl -n logging get svc`

### FluentBit Configuration for Kafka Target

Set the above Kafka Service name and port in the Fluentbit configuration.

#### Open config:

* `kubectl -n logging edit configmap fluent-bit-config`
* Set the `Brokers` to `Brokers=my-cluster-kafka-bootstrap:9092`.

#### Restart Fluentbit:

* `kubectl -n logging rollout restart ds/fluent-bit`


### Setup Quine

#### Create Quine Container

The below command will create the quine service in our Kubernetes cluster from the open source [thatdot/quine](https://hub.docker.com/r/thatdot/quine) Docker image.

```bash
kubectl -n logging create -f ./src/kubernetes/quine/quine-service-deployment.yaml
```

#### Get Kafka Topic used by Fluentbit:

Find the topic name which FluentBit will use for sending data, store for later use when configuring the Quine ingest. *See setting for `topics=`.*

```
kubectl -n logging get pods -l k8s-app=fluent-bit-logging --no-headers -o custom-columns=NAME:metadata.name | xargs kubectl -n logging logs | grep output:kafka
```

*Hint: Something like "ops.kube-logs-fluentbit.stream.json.001​"*


#### Test Topic with Kafka Consumer

Set above topic name to the `--topic` entry in the below command. You should see a stream of data that is coming from Fluentbit.

```bash
kubectl -n logging run kafka-consumer -ti --image=quay.io/strimzi/kafka:0.27.1-kafka-3.0.0 --rm=true --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --topic ops.kube-logs-fluentbit.stream.json.001 --from-beginning
```

#### Setup Quine Ingest Source

Using the above topic name setup a quine ingest.

*NOTE: This can be achieved using the API or to the Quine GUI using an ingress server proxying requests to the Web UI of Quine.*



### Commands

See `Makefile` for helpful commands using `make help`. These should help to manage the running Kuberntes cluser for this project.



## References

* [YouTube: Kubernetes pod autoscaling for beginners with kind](https://www.youtube.com/watch?v=FfDI08sgrYY) - Uses `Kind`.
* [Github: Kubernetes pod autoscaling for beginners with kind](https://github.com/marcel-dempers/docker-development-youtube-series/tree/master/kubernetes/autoscaling/components)

