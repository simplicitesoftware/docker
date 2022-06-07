#!/bin/bash

exit_with () {
	[ "$2" != "" ] && echo $2 >&2
	exit ${2:-1}
}

[ "$1" = "--help" ] && exit_with 1 "Usage: `basename $0`"

LOCK=/tmp/`basename $0 .sh`.lck
trap "rm -f $LOCK" TERM INT QUIT HUP
[ -f $LOCK ] && exit_with 2 "A build process is in process since `cat $LOCK`"
date > $LOCK

cd theia

IMG=simplicite/theia:latest
echo "========================================================"
echo "Building $IMG image..."
echo "========================================================"
DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
FROM=`grep '^FROM' Dockerfile | awk '{ print $2 }'`
docker pull $FROM
docker build --network host -t $IMG --build-arg THEIA_TAG=$TAG --build-arg BUILD_DATE=$DATE .  || exit_with 3 "Unable to build image $IMG"
echo "Done"
echo ""
echo "docker run -it --rm -p 127.0.0.1:3030:3030 --name=theia $IMG"
echo ""

cd ..

rm -f $LOCK
exit 0
