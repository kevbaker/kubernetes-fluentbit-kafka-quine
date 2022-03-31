DOCKER_IMAGE_NAME=kube-log-stream-stack-example
DOCKER_CONTAINER_NAME=kube-log-stack
build:
	docker build -t ${DOCKER_IMAGE_NAME} .

run:
	docker run -d -p 2222:22 --name ${DOCKER_CONTAINER_NAME} ${DOCKER_IMAGE_NAME}
	docker ps

shell:
	docker exec -it ${DOCKER_CONTAINER_NAME} /bin/bash

kill:
	docker stop ${DOCKER_CONTAINER_NAME} && docker rm ${DOCKER_CONTAINER_NAME}
reset:
	make kill
	make build
	make run
