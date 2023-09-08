#!/bin/bash

if [ "$1" = "" -o "$2" = "" -o "$1" = "--help" ]
then
	echo -e "\nUsage: \e[1m$(basename $0)\e[0m <repository> <tag(s)>\n" >&2
	exit 1
fi

REP=$1
shift

for TAG in $*
do
	echo "Deleting $REP/$TAG..."
	#ID=$(curl -s --head -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -u $DOCKER_PRIVATE_REGISTRY_USERNAME:$DOCKER_PRIVATE_REGISTRY_PASSWORD $DOCKER_PRIVATE_REGISTRY_URL/v2/$REP/manifests/$TAG | grep '^Docker-Content-Digest:' | awk '{print $2}' | sed 's/\r$//')
	#echo "    Image ID = [$ID]"
	#[ "$ID" != "" ] && curl -X DELETE -u $DOCKER_PRIVATE_REGISTRY_USERNAME:$DOCKER_PRIVATE_REGISTRY_PASSWORD $DOCKER_PRIVATE_REGISTRY_URL/v2/$REP/manifests/$ID
	echo regctl tag delete ${DOCKER_PRIVATE_REGISTRY_URL#http://}/$REP:$TAG
	echo "Done"
done

exit 0
