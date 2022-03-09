SHELL = /bin/bash
QUINE_DOCKER_CONTAINER_IMAGE_NAME="thatdot/quine"
QUINE_DOCKER_CONTAINER_NAME="quine"

help:
	@echo "\nTARGETS:\n"
	@make -qpRr | egrep -e '^[a-z].*:$$' | sed -e 's~:~~g' | sort
	@echo ""
list:
	make help


k-get-all:
	kubectl get services,deployments,pods --all-namespaces

k-kafka-consumer-reset:
	kubectl delete pod kafka-consumer -n kafka
	

k-kafka-consumer-start:
	kubectl -n logging run kafka-consumer -ti --image=quay.io/strimzi/kafka:0.27.1-kafka-3.0.0 --rm=true --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --topic ops.kube-logs-fluentbit.stream.json.001 --from-beginning
	

k-ubuntu-container-shell:
	kubectl exec --stdin --tty pod/ubuntu  -n logging  -- /bin/bash
	
k-kafka-shell:
	kubectl exec --stdin --tty pod/my-cluster-kafka-0  -n logging  -- /bin/bash

k-kafka-zoo-shell:
	kubectl exec --stdin --tty pod/my-cluster-zookeeper-0   -n logging  -- /bin/bash


docker-quine-local-run:
	docker run --name ${QUINE_DOCKER_CONTAINER_NAME} -dp 8080:8080 ${QUINE_DOCKER_CONTAINER_IMAGE_NAME} 
	docker ps|grep ${QUINE_DOCKER_CONTAINER_NAME}

docker-quine-local-kill:
	docker stop ${QUINE_DOCKER_CONTAINER_NAME}
	docker rm ${QUINE_DOCKER_CONTAINER_NAME}
