#!/bin/bash

LOCK=/tmp/$(basename $0 .sh).lck

exit_with () {
	[ "$2" != "" ] && echo -e $2 >&2
	rm -f $LOCK
	exit ${1:-0}
}

[ "$1" = "--help" ] && exit_with 1 "\nUsage: \e[1m$(basename $0)\e[0m\n"

trap "rm -f $LOCK" TERM INT QUIT HUP
[ -f $LOCK ] && exit_with 2 "A build process is in process since $(cat $LOCK)"
date > $LOCK

REGISTRY=registry.simplicite.io

IMG=$REGISTRY/theia:latest
echo "========================================================"
echo "Building $IMG image..."
echo "========================================================"
DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
FROM=$(grep '^FROM' Dockerfile | awk '{ print $2 }')
docker pull $FROM
docker build --network host -f theia/Dockerfile -t $IMG --build-arg THEIA_TAG=$TAG --build-arg BUILD_DATE=$DATE . || exit_with 3 "Unable to build image $IMG"
echo "Done"
echo ""
echo "docker run -it --rm -p 127.0.0.1:3030:3030 --name=theia $IMG"
echo ""

exit_with
