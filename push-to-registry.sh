#!/bin/bash

IMGS=${1:-server platform theia}

for IMG in $IMGS
do
	echo ""
	echo "------------------------------------"
	echo "$IMG"
	echo "------------------------------------"

	for TAG in `docker images | grep "^simplicite.$IMG" | awk '{print ":"$2}'`
	do
		echo ""
		echo "Pushing image $IMG$TAG to DockerHub registry"
		docker push simplicite/$IMG$TAG
		echo "Done"

		if [ "$DOCKER_PRIVATE_REGISTRY_HOST" != "" ]
		then
			echo "Pushing image $IMG$TAG to local registry $DOCKER_PRIVATE_REGISTRY_HOST"
			docker tag simplicite/$IMG$TAG $DOCKER_PRIVATE_REGISTRY_HOST/$IMG$TAG
			docker push $DOCKER_PRIVATE_REGISTRY_HOST/$IMG$TAG
			docker rmi $DOCKER_PRIVATE_REGISTRY_HOST/$IMG$TAG
			echo "Done"
		fi
	done
done
echo ""
exit 0

