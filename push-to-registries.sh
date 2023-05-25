#!/bin/bash

USAGE="\nUsage: \e[1m$(basename $0)\e[0m [--delete] <repository> [<tags>]\n"
if [ "$1" = "" -o "$1" = "--help" ]
then
	echo -e $USAGE >&2
	exit -1
fi

REGISTRY=registry.simplicite.io

DEL=0
if [ "$1" = "--delete" ]
then
	DEL=1
	shift
fi

PUB=0
if [ "$1" = "--public" ]
then
	PUB=1
	shift
fi

IMG=$1
shift

if [ $IMG != "server" -a $IMG != "platform" -a $IMG != "theia" -a $IMG != "vscode" -a $IMG != "oracle" ]
then
	echo -e $USAGE >&2
	exit -1
fi

[ -x /usr/bin/figlet ] && echo "" && /usr/bin/figlet -f small ${IMG^}

TAGS=$*
[ "$TAGS" = "" ] && TAGS=$(docker images | grep "^$REGISTRY.$IMG" | awk '{print $2}')

for TAG in $TAGS
do
	if [ $IMG != "server" -o "${TAG:(-4)}" != "base" ]
	then
		echo ""
		echo "------------------------------------"
		echo "Image $IMG:$TAG"
		echo "------------------------------------"
		echo ""

		if [ $PUB -eq 0 -a "$DOCKER_PRIVATE_REGISTRY_HOST" != "" ]
		then
			echo "Pushing image $IMG:$TAG to the local registry $DOCKER_PRIVATE_REGISTRY_HOST"
			docker tag $REGISTRY/$IMG:$TAG $DOCKER_PRIVATE_REGISTRY_HOST/$IMG:$TAG
			docker push $DOCKER_PRIVATE_REGISTRY_HOST/$IMG:$TAG
			docker rmi $DOCKER_PRIVATE_REGISTRY_HOST/$IMG:$TAG
			echo "Done"
		fi

		if [ $PUB -eq 1 ]
		then
			if [ $IMG = "server" -o $IMG = "platform" ]
			then
				echo "Pushing image $IMG:$TAG to the public DockerHub registry"
				docker tag $REGISTRY/$IMG:$TAG simplicite/$IMG:$TAG
				docker push simplicite/$IMG:$TAG
				docker rmi simplicite/$IMG:$TAG
				echo "Done"
			fi
		fi

		[ $DEL -eq 1 ] && docker rmi $REGISTRY/$IMG:$TAG
	fi
done
echo ""
		
# Garbage collection if local private registry
[ "$DOCKER_PRIVATE_REGISTRY_CONTAINER" != "" ] && docker exec $DOCKER_PRIVATE_REGISTRY_CONTAINER /bin/registry garbage-collect -m /etc/docker/registry/config.yml

exit 0

