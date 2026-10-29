#!/bin/bash

USAGE="\nUsage: \e[1m$(basename $0)\e[0m [--delete] <repository> [<tags>]\n"
if [ "$1" = "" -o "$1" = "--help" ]
then
	echo -e $USAGE >&2
	exit 1
fi

if [ "$DOCKER_PRIVATE_REGISTRY_HOST" = "" ]
then
	echo -e "\nError: DOCKER_PRIVATE_REGISTRY_HOST environment variable is not defined" >&2
	exit 2
fi
 
REGISTRY=registry.simplicite.io

DEL=0
if [ "$1" = "--delete" ]
then
	DEL=1
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
[ "$TAGS" = "" ] && TAGS=$(docker images $REGISTRY/$IMG --format '{{.Tag}}' | sort | xargs)

for TAG in $TAGS
do
	echo ""
	echo "------------------------------------"
	echo "Pushing image $IMG:$TAG to the local registry $DOCKER_PRIVATE_REGISTRY_HOST"
	echo "------------------------------------"
	echo ""
	docker tag $REGISTRY/$IMG:$TAG $DOCKER_PRIVATE_REGISTRY_HOST/$IMG:$TAG
	docker push $DOCKER_PRIVATE_REGISTRY_HOST/$IMG:$TAG
	docker rmi $DOCKER_PRIVATE_REGISTRY_HOST/$IMG:$TAG
	echo "Done"

	[ $DEL -eq 1 ] && docker rmi $REGISTRY/$IMG:$TAG
done
echo ""
		
# Garbage collection if local private registry
[ "$DOCKER_PRIVATE_REGISTRY_CONTAINER" != "" ] && docker exec $DOCKER_PRIVATE_REGISTRY_CONTAINER /bin/registry garbage-collect -m /etc/docker/registry/config.yml > /dev/null 2>&1

exit 0
