#!/bin/bash

if [ "$1" = "--help" ]
then
	echo "Usage: `basename $0`" >&2
	exit 1
fi

LOCK=/tmp/`basename $0 .sh`.lck
if [ -f $LOCK ]
then
	echo "A build process is in process since `cat $LOCK`" >&2
	exit 2
fi
date > $LOCK

TAGS="latest next"
[ "$1" != "" ] && TAGS=$1

for TAG in $TAGS
do
	IMG=simplicite/theia:$TAG
	echo "-- $IMG ------------------"
	DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
	FROM=`grep FROM Dockerfile-theia | awk '{ print $2 }'`
	sudo docker pull $FROM
	sudo docker build --network host -f Dockerfile-theia -t $IMG --build-arg tag=$TAG --build-arg date=$DATE .
	echo "Done"
	echo "sudo docker run -it --rm -p 3030:3030 $IMG"
	echo "sudo docker push $IMG"
	echo ""
done

rm -f $LOCK
exit 0
