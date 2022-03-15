# NOTES

## Old README


# Kubernetes Fluentbit Kafka PoC


## Steps

* [x] Setup Minikube
* [x] Setup Fluentbit in k8s
* [x] Setup Kafka in k8s
* [x] Connect Fluentbit and Kafka
* [x] View logging in Kafka
* [x] Build Quine container image
* [x] Deploy Quine container on Docker
* [x] Play with Quine container API on docker, it works!
* [x] Deploy Quine service to minikube (apply yaml)
* [x] Play with Quine container on minikube (run, api call)
* [x] [Setup Quine ingest](https://quine.io/docs/getting-started/quick-start)
* [x] Add custom application container 
* [x] Setup auto scaling
* [ ] Generate load on application container
* [ ] Export Logs to share




## Setup

### Namespace
kubectl create namespace logging
​
### FluentBit setup
https://github.com/fluent/fluent-bit-kubernetes-logging
​
Note: skip RBAC resources creation for minikube (RBAC is for real cluster, not minikube)

```
kubectl -n logging create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/fluent-bit-service-account.yaml
kubectl -n logging create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/output/kafka/fluent-bit-configmap.yaml
kubectl -n logging create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/output/kafka/fluent-bit-ds.yaml
```
​
### Kafka setup

https://strimzi.io/quickstarts/

```
kubectl -n logging create -f 'https://strimzi.io/install/latest?namespace=logging'
kubectl -n logging apply -f https://strimzi.io/examples/latest/kafka/kafka-persistent-single.yaml
kubectl -n logging wait kafka/my-cluster --for=condition=Ready --timeout=300s 
​
# Find the name of Kafka service on minikube (hint: my-cluster-kafka-bootstrap:9092)
kubectl -n logging get svc
```
​
### FluentBit configuration
#### Edit FluentBit configmap (set correct Kafka adddress)
Set output-kafka.conf value to `Brokers=my-cluster-kafka-bootstrap:9092`

```
kubectl -n logging edit configmap fluent-bit-config
```
​
#### Restart fluent-bit daemon set

```
kubectl -n logging rollout restart ds/fluent-bit
```
​
#### Find the topic name which FluentBit will use for sending data

```
kubectl -n logging get pods -l k8s-app=fluent-bit-logging --no-headers -o custom-columns=NAME:metadata.name | xargs kubectl -n logging logs | grep output:kafka
```

EXAMPLE: ops.kube-logs-fluentbit.stream.json.001​


### Kafka: receive messages for topic

Topic: `ops.kube-logs-fluentbit.stream.json.001`
​
The output will show the contents of minikube node logs by default (current fluentbit config consumes this logs and sends to Kafka topic)

```bash
kubectl -n logging run kafka-consumer -ti --image=quay.io/strimzi/kafka:0.27.1-kafka-3.0.0 --rm=true --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --topic ops.kube-logs-fluentbit.stream.json.001 --from-beginning
```

#### Output to file

```bash
kubectl -n logging run kafka-consumer -ti --image=quay.io/strimzi/kafka:0.27.1-kafka-3.0.0 --rm=true --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --topic ops.kube-logs-fluentbit.stream.json.001 --from-beginning > kafka-topic-output.txt
```



## Quine: Setup 

### Build Quine container

```
cd src/docker/quine
docker build -t quine-service .
cd -
```

### Push Quine container to Kubernetes

#### Minikube:

```
minikube image load quine-service
```

#### Kind

load:

```
kind load docker-image quine-service
```

view images:
```
docker exec -ti kind-control-plane crictl images
```


### Forward traffic to quine

Setup nginx on the host machine to forward traffic to quine. 



#### Install Nginx

`sudo apt install nginx`

#### Nginx Configuration

NOTE: Change the `proxy_pass` configuration to the `internal ip` and `internal port` to the port of your quine service in the Kubernetes cluster.

```yaml
server {
	listen 80 default_server;
	listen [::]:80 default_server;

	index index.html index.htm index.nginx-debian.html;

	server_name _;

	location / {
	    proxy_pass http://172.18.0.2:32449;
	    proxy_http_version 1.1;
	    proxy_set_header Upgrade $http_upgrade;
	    proxy_set_header Connection "Upgrade";
	    proxy_set_header Host $host;
	}
}
```




### View Quine from browser

The below URL uses the external DNS of the VM hosting Kind Kubernetes routed through Nginx.

```bash
curl -X 'GET'   'http://kb-kube1.eastus.cloudapp.azure.com/api/v1/admin/build-info'   -H 'accept: application/json'|jq
```

Also the Quine UI can be access from the browser at: http://kb-kube1.eastus.cloudapp.azure.com/



### Deploy Quine as service in Kubernetes

```bash
kubectl -n logging apply -f src/kubernetes/quine/quine-service-deployment.yaml
```

## Quine Configuration

### Add ingest

Setup quine ingest to `fluentbit-kafka-topic` on Kafka Bootstrap Service

NOTE: Service URL can be found with: `kubectl get service my-cluster-kafka-bootstrap  -n logging`
NOTE: Change external URL in curl path and `bootstrapServers` param below.

```bash
curl -X 'POST' \
  'http://kb-kube1.eastus.cloudapp.azure.com/api/v1/ingest/fluentbit-kafka-topic' \
  -H 'accept: */*' \
  -H 'Content-Type: application/json' \
  -d '{
  "topics": [
    "ops.kube-logs-fluentbit.stream.json.001"
  ],
  "bootstrapServers": "10.96.6.119:9092",
  "groupId": "quine-e1-ingester",
  "type": "KafkaIngest"
}'
```





### Deploy Example App Service to Kubernetes

This will deploy an example app service to Minikube

```bash
kubectl -n apps apply -f src/kubernetes/service-one/service-one-deployment.yaml
```

kubectl -n logs apply -f src/kubernetes/service-one/service-one-deployment.yaml

### Setup Minikube Metrics Server

For stats used in autoscaling

```bash
minikube addons enable heapster
minikube addons enable metrics-server
minikube addons list
```


### Setup Autoscale for Example App Service

#### Yaml

```bash
kubectl apply -f  src/kubernetes/service-one/service-one-autoscale-hpa.yaml
```


Doesn't work
```bash
kubectl apply -f  src/kubernetes/service-one/service-one-hpa-v2.yaml 
```


#### Scaling

## Manual increase pods
kubectl scale deploy/application-cpu --replicas 1



### Auto Scaling

```bash
kubectl autoscale deployment service-one -n logging --cpu-percent=50 --min=1 --max=10
```


```bash
kubectl autoscale deploy/application-cpu --cpu-percent=95 --min=1 --max=10
```


## Fix HPA

```
kubectl delete clusterrole system:heapster 
```

[Make metrics-server work out of the box with kubeadm](https://particule.io/en/blog/kubeadm-metrics-server/)

https://www.ibm.com/docs/en/spp/10.1.8?topic=prerequisites-kubernetes-verifying-whether-metrics-server-is-running



https://stackoverflow.com/questions/59262706/k8s-hpa-cant-get-the-cpu-information


kubectl edit deployment -n kube-system metrics-server

kubectl get deployment -n kube-system metrics-server -o yaml 

kubectl get service hellworldexample-helloworld -n default -o yaml
args:
  - --kubelet-insecure-tls
  - --kubelet-preferred-address-types=InternalIP
  - --cert-dir=/tmp
  - --secure-port=4443

--kubelet-insecure-tls=true



```bash
kubectl apply -f  src/kubernetes/hpa-fix/hpa-cluster-role-fix.yaml
```


#### Watch hpa

[NOTE on HPA not reporting CPU](https://github.com/kubernetes/minikube/issues/5642)

kubectl get hpa service-one -n logging  --watch

watch kubectl -n logging get all 

watch kubectl top pod -n logging

kubectl get --raw "/apis/metrics.k8s.io/v1beta1/pods"

watch -d -n1 kubectl describe PodMetrics service-one-55988fb944-6btk9  -n logging

watch kubectl top pods



##### Get CPU/Memory of each

```bash
kubectl top pods --all-namespaces
```


##### Describe Pod Detail

```
kubectl describe hpa service-one -n logging 
```

## Generate Load on Pod


### Possibly use Apache Bench

```bash
ab -n 100 -c 100 'http://192.168.64.10:32605/fibonacci?count=10000'
```
https://blog.dennisokeeffe.com/blog/2020-07-06-deploying-a-serverless-go-api

### Possibly use Pod for Traffic Generation

This works well

```bash
kubectl apply -f src/kubernetes/traffic-generator/traffic-generator-pod.yaml 
kubectl exec -it traffic-generator -- sh
apk add --no-cache wrk
wrk -c 5 -t 5 -d 99999 -H "Connection:Close" http://application-cpu
```



## Manual Scale

kubectl scale -n logging deployment service-one --replicas=2



## Add Tools Container

This can be used to test code in the cluster.

```
kubectl -n logging apply -f src/kubernetes/ubuntu-pod.yaml
```

## References

* https://github.com/fluent/fluent-bit-kubernetes-logging#details
* https://quine.io/docs/getting-started/exploration-ui
* [k9s for Kubernetes Cluster Top](https://github.com/derailed/k9s) - command like `top` for Kubernetes.
* [Kubernetes pod autoscaling for beginners with kind](https://www.youtube.com/watch?v=FfDI08sgrYY) - Uses `Kind`.
* [Github: Kubernetes pod autoscaling for beginners with kind](https://github.com/marcel-dempers/docker-development-youtube-series/tree/master/kubernetes/autoscaling/components)
* [Kubernetes Metrics Server](https://github.com/kubernetes-sigs/metrics-server)
* [Github: Horizontal Pod Scaling Overview](https://github.com/marcel-dempers/docker-development-youtube-series/tree/master/kubernetes/autoscaling)


## NOTES

JSON for Kafka Ingest Configuration
```json
{
  "topics": [
    "ops.kube-logs-fluentbit.stream.json.001"
  ],
  "bootstrapServers": "my-cluster-kafka-bootstrap:9092",
  "groupId": "quine-e1-ingester",
  "type": "KafkaIngest"
}
```





## Overview

Notes for experimenting with setup

## Notes

Export logs from kind:

`kind export logs ~/logs`


Zookeeper settings:

```yaml
ssl.clientAuth=need
ssl.keyStore.type=PKCS12
ssl.keyStore.location=/tmp/zookeeper/cluster.keystore.p12
dataDir=/var/lib/zookeeper/data
4lw.commands.whitelist=*
ssl.trustStore.location=/tmp/zookeeper/cluster.truststore.p12
syncLimit=2
ssl.quorum.keyStore.password=b1_L8jWUdKvT2pXnMHh45lT-4RU6Vt4t
ssl.quorum.trustStore.password=b1_L8jWUdKvT2pXnMHh45lT-4RU6Vt4t
ssl.keyStore.password=b1_L8jWUdKvT2pXnMHh45lT-4RU6Vt4t
standaloneEnabled=false
initLimit=5
secureClientPort=2181
ssl.quorum.trustStore.type=PKCS12
serverCnxnFactory=org.apache.zookeeper.server.NettyServerCnxnFactory
ssl.quorum.keyStore.location=/tmp/zookeeper/cluster.keystore.p12
autopurge.purgeInterval=1
sslQuorum=true
ssl.quorum.trustStore.location=/tmp/zookeeper/cluster.truststore.p12
reconfigEnabled=true
ssl.trustStore.password=b1_L8jWUdKvT2pXnMHh45lT-4RU6Vt4t
ssl.quorum.keyStore.type=PKCS12
ssl.quorum.clientAuth=need
ssl.trustStore.type=PKCS12
tickTime=2000
dynamicConfigFile=/tmp/zookeeper.properties.dynamic.100000000
```

[Kind load docker-image](https://iximiuz.com/en/posts/kubernetes-kind-load-docker-image/)
[Kind load docker-image Quickstart](https://kind.sigs.k8s.io/docs/user/quick-start/#loading-an-image-into-your-cluster)

    
### Get `kind` images

```bash
docker exec -ti kind-control-plane crictl images
```





## Steps

See README

* [x] - installed latest quine
* [ ] - configure quine
* [ ] - setup ingest


## Forward traffic to quine

Setup nginx on the host machine to forward traffic to quine. 



### Install Nginx

`sudo apt install nginx`

### Nginx Configuration

NOTE: Change the `proxy_pass` configuration to the `internal ip` and `internal port` to the port of your quine service in the Kubernetes cluster.

```
server {
	listen 80 default_server;
	listen [::]:80 default_server;

	index index.html index.htm index.nginx-debian.html;

	server_name _;

	location / {
	    proxy_pass http://172.18.0.2:32449;
	}
}
```

curl -X 'GET'   'http://kb-kube1.eastus.cloudapp.azure.com/api/v1/admin/build-info'   -H 'accept: application/json'|jq



https://www.digitalocean.com/community/tutorials/how-to-install-apache-kafka-on-ubuntu-20-04


kubectl delete pods kafka-consumer --grace-period=0 --force
