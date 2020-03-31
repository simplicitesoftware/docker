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
sudo docker pull docker.io/openjdk:13-alpine
echo "Done"

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
		sudo docker build --network host -f Dockerfile-$TAG -t $SERVER:$TAG$TAGEXT .
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
