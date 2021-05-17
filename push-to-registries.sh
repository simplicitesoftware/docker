#!/bin/bash

USAGE="Usage: `basename $0` <server|platform|theia> [<tags>]"
if [ "$1" = "" -o "$1" = "--help" ]
then
	echo $USAGE >&2
	exit -1
fi

IMG=$1
shift

if [ $IMG != "server" -a $IMG != "platform" -a $IMG != "theia" ]
then
	echo $USAGE >&2
	exit -1
fi

[ -x /usr/bin/figlet ] && echo "" && /usr/bin/figlet -f small ${IMG^}

TAGS=$*
[ "$TAGS" = "" ] && TAGS=`docker images | grep "^simplicite.$IMG" | awk '{print $2}'`

for TAG in $TAGS
do
	echo ""
	echo "------------------------------------"
	echo "Image $IMG:$TAG"
	echo "------------------------------------"
	echo ""
	echo "Pushing image $IMG:$TAG to DockerHub registry"
	docker push simplicite/$IMG:$TAG
	echo "Done"

	if [ "$DOCKER_PRIVATE_REGISTRY_HOST" != "" ]
	then
		echo "Pushing image $IMG:$TAG to local registry $DOCKER_PRIVATE_REGISTRY_HOST"
		docker tag simplicite/$IMG:$TAG $DOCKER_PRIVATE_REGISTRY_HOST/$IMG:$TAG
		docker push $DOCKER_PRIVATE_REGISTRY_HOST/$IMG:$TAG
		docker rmi $DOCKER_PRIVATE_REGISTRY_HOST/$IMG:$TAG
		# Garbage collection if local private registry
		[ "$DOCKER_PRIVATE_REGISTRY_CONTAINER" != "" ] && docker exec $DOCKER_PRIVATE_REGISTRY_CONTAINER /bin/registry garbage-collect -m /etc/docker/registry/config.yml
		echo "Done"
	fi
done
echo ""

exit 0

