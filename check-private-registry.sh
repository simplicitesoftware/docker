#!/bin/bash

if [ "$1" = "--help" ]
then
	echo "Usage: `basename $0` [-r|--raw] [\"<repository, defaults to all repositories>\"]" >&2
	exit 1
fi

RAW=0
if [ "$1" = "-r" -o "$1" = "--raw" ]
then
	RAW=1
	shift
fi

REPS=${1:-`curl -s -u $DOCKER_PRIVATE_REGISTRY_USERNAME:$DOCKER_PRIVATE_REGISTRY_PASSWORD $DOCKER_PRIVATE_REGISTRY_URL/v2/_catalog | jq -r '.repositories[]' | sort`}

for REP in $REPS
do
	if [ $RAW -eq 0 ]
	then
		echo ""
		[ -x /usr/bin/figlet ] && /usr/bin/figlet -f small ${REP^} || printf "========== \033[1m%s\033[0m ==========\n\n" $REP
	fi
	TAGS=`curl -s -u $DOCKER_PRIVATE_REGISTRY_USERNAME:$DOCKER_PRIVATE_REGISTRY_PASSWORD $DOCKER_PRIVATE_REGISTRY_URL/v2/$REP/tags/list | jq -r '.tags[]' | sort -r`
	for TAG in $TAGS
	do
		ID=`curl -s --head -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -u $DOCKER_PRIVATE_REGISTRY_USERNAME:$DOCKER_PRIVATE_REGISTRY_PASSWORD $DOCKER_PRIVATE_REGISTRY_URL/v2/$REP/manifests/$TAG | grep '^Docker-Content-Digest:' | sed 's/sha256://' | awk '{print substr($2,0,16)}'`
		[ $RAW -eq 0 ] && printf "%s \033[31;1m%s\033[0m%s\n" $ID $TAG || echo "$ID $TAG"
	done
done
[ $RAW -eq 0 ] && echo ""

exit 0
