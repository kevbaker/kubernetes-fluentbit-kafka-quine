# NOTES

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
