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

BASE="simplicite/ide-base:latest"
docker inspect $BASE > /dev/null 2>&1
if [ $? -ne 0 ]
then
	echo "-- $BASE ------------------"
	docker build --network host -t $BASE -f Dockerfile-ide-base .
	echo ""
fi

cd vscode

TAGS="latest"
[ "$1" != "" ] && TAGS=$1

for TAG in $TAGS
do
	IMG=simplicite/vscode:$TAG
	echo "-- $IMG ------------------"
	DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
	docker build --network host -t $IMG --build-arg BUILD_DATE=$DATE .
	echo ""
	echo "docker run -it --rm -p 3030:3030 --name=vscode $IMG"
	echo ""
	echo "docker push $IMG"
	echo ""
done

cd ..

rm -f $LOCK
exit 0
