#!/bin/bash

TOKEN=`curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'$DOCKERHUB_USERNAME'", "password": "'$DOCKERHUB_PASSWORD'"}' https://hub.docker.com/v2/users/login/ | jq -r '.token'`
if [ "$TOKEN" = "" ]
then
	echo "Authentication error" >&2
	exit 1
fi

echo ""
ORG=simplicite
for REP in `curl -s -H "Authorization: JWT $TOKEN" https://hub.docker.com/v2/repositories/$ORG/?page_size=20 | jq -r '.results[].name' | sort`
do
	echo "========================================================"
	printf "== \033[1m%-50s\033[0m ==\n" $ORG/$REP
	echo "========================================================"
	curl -s -H "Authorization: JWT $TOKEN" https://hub.docker.com/v2/repositories/$ORG/$REP/tags/?page_size=50 | jq -r '.results[] | "\(.last_updated) \(.name) \(.images[].digest)"' | sort -r | sed 's/T/ /;s/\.[0-9]*Z//;s/sha256://' | awk '{ printf "\033[32m%-10s %-8s\033[0m %s \033[1m\033[34m%-20s\033[0m\n", $1, $2, substr($4,0,16), $3 }' || exit 2
	echo ""
done
