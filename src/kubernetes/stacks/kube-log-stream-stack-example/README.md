# Full Stack Docker Image

## Overview

Create a Docker image that builds the entire infrastructure. This is Docker in Docker.

## Why?

It is a simple way to create an image of the entire stack for others to install and run locally.

## Build

This docker image once built will contain the complete stack.

`docker build -t kube-log-stream-stack-example .`

## Run

`docker run -d -p 2222:22 --name log-stack kube-log-stream-stack-example`


## Shell

`docker exec -it log-stack /bin/bash`
