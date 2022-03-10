

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








### Quine Findings

*Quine configurations, outputs and findings here.*



## Project Setup

This project was based on the great tutorial from "That DevOps Guy" to setup a Kind configuration for autoscaling Kubernetes. It was extended with Fluentbit, Kafka and Quine. Details are below.

## Setup Kubernetes Horizontal Autoscale

Using the tutorial from "The DevOps Guy" we will setup a Kubernetes cluster with horizontal pod scaling.

* :tv: [Kubernetes pod autoscaling for beginners with kind](https://www.youtube.com/watch?v=FfDI08sgrYY) - Uses `Kind`.


## Setup Fluentbit


## Setup Kafka


## Setup Quine









### Commands

See `Makefile` for helpful commands using `make help`. These should help to manage the running Kuberntes cluser for this project.

### Steps

