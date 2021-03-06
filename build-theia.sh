#!/bin/bash

if [ "$1" = "--help" ]
then
	echo "Usage: `basename $0` [<tag(s)>]" >&2
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

cd theia

TAGS="latest next"
[ "$1" != "" ] && TAGS=$1

for TAG in $TAGS
do
	IMG=simplicite/theia:$TAG
	echo "========================================================"
	echo "Building $IMG image..."
	echo "========================================================"
	DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
	FROM=`grep '^FROM' Dockerfile | awk '{ print $2 }'`
	docker pull $FROM
	docker build --network host -t $IMG --build-arg THEIA_TAG=$TAG --build-arg BUILD_DATE=$DATE .
	echo "Done"
done

for TAG in $TAGS
do
	IMG=simplicite/theia:$TAG
	echo "-- $IMG ------------------"
	echo ""
	echo "docker run -it --rm --init -p 3030:3030 --name=theia  $IMG"
	echo ""
	echo "docker push $IMG"
	echo ""
done

cd ..

rm -f $LOCK
exit 0
