#!/bin/bash

if [ "$1" = "--help" ]
then
	echo "Usage: `basename $0`" >&2
	exit 1
fi

LOCK=/tmp/`basename $0 .sh`.lck
trap "rm -f $LOCK" TERM INT QUIT HUP
if [ -f $LOCK ]
then
	echo "A build process is in process since `cat $LOCK`" >&2
	exit 2
fi
date > $LOCK

cd hsqldb

IMG=simplicite/hsqldb:latest
echo "========================================================"
echo "Building $IMG image..."
echo "========================================================"
DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
FROM=`grep '^FROM' Dockerfile | awk '{ print $2 }'`
sudo docker pull $FROM
sudo docker build --network host -t $IMG --build-arg BUILD_DATE=$DATE .
echo "Done"

echo "-- $IMG ------------------"
echo ""
echo "sudo docker run -it --rm -p 9901:9001 $IMG"
echo ""
echo "sudo docker push $IMG"
echo ""

cd ..

rm -f $LOCK
exit 0