#!/bin/bash

if [ "$1" = "--help" ]
then
	echo "Usage: `basename $0` [<tag(s)> [<server(s)>]]" >&2
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

TAGS="centos centos-openjdk centos8 centos8-openjdk adoptopenjdk-hotspot adoptopenjdk-openj9"
[ "$1" != "" ] && TAGS=$1
#SRVS="tomcat tomee"
SRVS=tomcat
[ "$2" != "" ] && SRVS=$2

SERVER=simplicite/server

for SRV in $SRVS
do
	echo "Updating $SRV.git"
	cd $SRV.git
	git config remote.origin.fetch 'refs/heads/*:refs/heads/*'
	git fetch --verbose --all --force
	cd ..
	echo "Done"

	echo "Checkouting $SRV as tomcat..."
	rm -fr tomcat
	mkdir tomcat
	git --work-tree=tomcat --git-dir=$SRV.git checkout -f master
	rm -f tomcat/*.bat tomcat/bin/*.bat tomcat/bin/*.exe tomcat/bin/*.dll
	echo "Done"

	TAGEXT=""
	[ $SRV != "tomcat" ] && TAGEXT="-$SRV"
	for TAG in $TAGS
	do
		echo "========================================================"
		echo "Building $SERVER:$TAG$TAGEXT image..."
		echo "========================================================"
		DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
		FROM=`grep FROM Dockerfile-$TAG | awk '{ print $2 }'`
		sudo docker pull $FROM
		sudo docker build --network host -f Dockerfile-$TAG -t $SERVER:$TAG$TAGEXT --build-arg date=$DATE .
		if [ $TAG = "centos-openjdk" -a $SRV = "tomcat" ]
		then
			sudo docker build --network host -f Dockerfile-centos-devel -t $SERVER:centos-devel .
		fi
		echo "Done"
	done
done
rm -fr tomcat

echo ""
for SRV in $SRVS
do
	TAGEXT=""
	[ $SRV != "tomcat" ] && TAGEXT="-$SRV"
	for TAG in $TAGS
	do
		echo "-- $SERVER:$TAG$TAGEXT ------------------"
		echo "sudo docker run -it --rm -p 9090:8080 -p 9443:8443 $SERVER:$TAG$TAGEXT"
		echo "sudo docker push $SERVER:$TAG$TAGEXT"
		if [ $TAG = "centos" -a $SRV = "tomcat" ]
		then
			echo "sudo docker tag $SERVER:$TAG $SERVER:latest"
			echo "sudo docker push $SERVER:latest"
			echo "sudo docker rmi $SERVER:latest"
		fi
		if [ $TAG = "centos-openjdk" -a $SRV = "tomcat" ]
		then
			echo "sudo docker push $SERVER:centos-devel"
		fi
		echo ""
	done
done

rm -f $LOCK
exit 0
