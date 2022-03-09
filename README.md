# Kubernetes / Quine Project

---
<p align="center" width="100%">
<img src="extra/images/Kubernetes_Logo.png" height="50" style="padding-right:10%">

<img src="extra/images/Fluentbit_Logo.png" height="50" style="padding-right:10%">

<img src="extra/images/Kafka_Logo.png" height="40" style="padding-right:10%">

<img src="extra/images/Quine_Logo.svg" height="40" style="padding-right:10%"> 
</p>

---


## Overview

This is a project to demonstrate Kubernetes Cluster logging integrated with Quine.

---
## Project Stack

- **Kind** - A tool for running local Kubernetes clusters.
- **Kubernetes** - Container Orchestration System.
- **Fluentbit** - A scalable logging and metrics processor and forwarder.
- **Kafka** - A platform for handling real-time data feeds used to stream logs messages.
- **Quine** - Streaming graph system that connects to the log data streams and builds high-volume data into a stateful graph for analysis.



---
## Outcomes

Below are the outcomes from the project.

### Sample Data

Here is sample data used to form the Quine "standing query".

#### Sample Data File

Here is a link to a reference data file exported from an active Kafka log stream.


#### Data File Log Samples

Here are sample log file snippets exported from an active Kafka log stream.

### Quine Findings

*Quine configurations, outputs and findings here.*



## Project Setup

Here are instructions on setting up this project.

### Commands

See `Makefile` for helpful commands using `make help`. These should help to manage the running Kuberntes cluser for this project.

### Steps

