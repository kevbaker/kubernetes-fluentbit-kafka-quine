

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

* :pushpin: one sample
* :pushpin: two sample
* :pushpin: three sample



##### horizontalpodautoscaling

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


### Setup Kubernetes Horizontal Autoscale



### Setup Fluentbit



### Setup Kafka



### Setup Quine









### Commands

See `Makefile` for helpful commands using `make help`. These should help to manage the running Kuberntes cluser for this project.



## References

* [YouTube: Kubernetes pod autoscaling for beginners with kind](https://www.youtube.com/watch?v=FfDI08sgrYY) - Uses `Kind`.
* [Github: Kubernetes pod autoscaling for beginners with kind](https://github.com/marcel-dempers/docker-development-youtube-series/tree/master/kubernetes/autoscaling/components)
* [Kubernetes/Quine Azure VM using the above setup](http://40.87.90.44)
