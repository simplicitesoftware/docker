#!/bin/bash

if [ "$1" = "--help" ]
then
	echo "Usage: `basename $0` [<tag(s)> [<server(s)>]]" >&2
	exit 1
fi

LOCK=/tmp/`basename $0 .sh`.lck
if [ -f $LOCK ]
then
	echo "A build process is in process since `cat $LOCK`" >&2
	exit 2
fi
date > $LOCK

TAGS="centos alpine"
[ "$1" != "" ] && TAGS=$1
#SRVS="tomcat tomee"
SRVS=tomcat
[ "$2" != "" ] && SRVS=$2

SERVER=simplicite/server

echo "Updating base images..."
sudo docker pull docker.io/centos:7
sudo docker pull docker.io/centos:8
sudo docker pull docker.io/openjdk:8-alpine
sudo docker pull docker.io/openjdk:12-alpine
sudo docker pull docker.io/openjdk:13-alpine
echo "Done"

for SRV in $SRVS
do
	echo "Copying $SRV..."
	rm -fr tomcat
	mkdir tomcat
	git --work-tree=tomcat --git-dir=$SRV.git checkout -f master
	echo "Done"

	TAGEXT=""
	[ $SRV != "tomcat" ] && TAGEXT="-$SRV"
	for TAG in $TAGS
	do
		echo "========================================================"
		echo "Building $SERVER:$TAG$TAGEXT image..."
		echo "========================================================"
		sudo docker build -f Dockerfile-$TAG -t $SERVER:$TAG$TAGEXT .
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
			echo "sudo docker tag $SERVER:$TAG$TAGEXT $SERVER:latest"
			echo "sudo docker push $SERVER:latest"
			echo "sudo docker rmi $SERVER:latest"
		fi
		echo ""
	done
done

rm -f $LOCK
exit 0
