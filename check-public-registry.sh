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


TOKEN=`curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'$DOCKER_REGISTRY_USERNAME'", "password": "'$DOCKER_REGISTRY_PASSWORD'"}' ${DOCKER_REGISTRY_URL:-https://hub.docker.com}/v2/users/login/ | jq -r '.token'`
if [ "$TOKEN" = "" ]
then
	echo "Authentication error" >&2
	exit 1
fi

ORG=${ORG:-simplicite}
REPS=${1:-`curl -s -H "Authorization: JWT $TOKEN" ${DOCKER_REGISTRY_URL:-https://hub.docker.com}/v2/repositories/$ORG/?page_size=20 | jq -r '.results[].name' | sort`}

for REP in $REPS
do
	if [ $RAW -eq 0 ]
	then
		echo ""
		[ -x /usr/bin/figlet ] && /usr/bin/figlet -f small ${REP^} || printf "========== \033[1m%s\033[0m ==========\n\n" $REP
		curl -s -H "Authorization: JWT $TOKEN" ${DOCKER_REGISTRY_URL:-https://hub.docker.com}/v2/repositories/$ORG/$REP/tags/?page_size=100 | jq -r '.results[] | "\(.last_updated) \(.name) \(.images[].digest)"' | sort -r | sed 's/T/ /;s/\.[0-9]*Z//;s/sha256://' | awk '{ printf "\033[34;1m%-10s %-8s\033[0m %s \033[31;1m%s\033[0m\n", $1, $2, substr($4,0,16), $3 }' || exit 2
	else
		curl -s -H "Authorization: JWT $TOKEN" ${DOCKER_REGISTRY_URL:-https://hub.docker.com}/v2/repositories/$ORG/$REP/tags/?page_size=100 | jq -r '.results[] | "\(.last_updated) \(.name) \(.images[].digest)"' | sort -r | sed 's/T/ /;s/\.[0-9]*Z//;s/sha256://' | awk '{ printf "%s %s\n", substr($4,0,16), $3 }' || exit 2
	fi
done
[ $RAW -eq 0 ] && echo ""

exit 0
