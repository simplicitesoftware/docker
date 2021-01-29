#!/bin/bash

if [ "$1" = "--help" ]
then
	echo "Usage: `basename $0` [\"<repository, e.g. platfom or server, default to all repositories>\"]" >&2
	exit 1
fi

TOKEN=`curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'$DOCKERHUB_USERNAME'", "password": "'$DOCKERHUB_PASSWORD'"}' https://hub.docker.com/v2/users/login/ | jq -r '.token'`
if [ "$TOKEN" = "" ]
then
	echo "Authentication error" >&2
	exit 1
fi

ORG=${ORG:-simplicite}
REPOS=$1
[ "$REPOS" = "" ] && REPOS=`curl -s -H "Authorization: JWT $TOKEN" https://hub.docker.com/v2/repositories/$ORG/?page_size=20 | jq -r '.results[].name' | sort`

[ -x /usr/bin/figlet ] && echo "" && /usr/bin/figlet -f small ${ORG^}
echo ""
for REP in $REPOS
do
	echo "========================================================"
	printf "== \033[1m%-50s\033[0m ==\n" $ORG/$REP
	echo "========================================================"
	curl -s -H "Authorization: JWT $TOKEN" https://hub.docker.com/v2/repositories/$ORG/$REP/tags/?page_size=50 | jq -r '.results[] | "\(.last_updated) \(.name) \(.images[].digest)"' | sort -r | sed 's/T/ /;s/\.[0-9]*Z//;s/sha256://' | awk '{ printf "\033[34;1m%-10s %-8s\033[0m %s \033[31;1m%-20s\033[0m\n", $1, $2, substr($4,0,16), $3 }' || exit 2
	echo ""
done

exit 0
