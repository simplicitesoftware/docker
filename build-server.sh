#!/bin/bash

if [ "$1" = "--help" ]
then
	echo "Usage: `basename $0` [\"<variants(s), defaults to all>\" [\"<server(s)>, defaults to tomcat]\"]" >&2
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

echo ""
echo "--------------------------------------------------------"

TAGS="centos centos8 adoptopenjdk-hotspot adoptopenjdk-openj9 devel"
[ "$1" != "" ] && TAGS=$1
echo "Variants(s) = $TAGS"

#SRVS="tomcat tomee"
SRVS=tomcat
[ "$2" != "" ] && SRVS=$2
echo "Server(s) = $SRVS"

echo "--------------------------------------------------------"
echo ""

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

	SRVEXT=""
	[ $SRV != "tomcat" ] && SRVEXT="-$SRV"

	for TAG in $TAGS
	do
		JVMS="latest"
		[ $TAG = "centos" -o $TAG = "centos8" ] && JVMS="latest 11 1.8.0"

		for JVM in $JVMS
		do
			JVMEXT=""
			[ $JVM != "latest" ] && JVMEXT="-openjdk-$JVM"

			echo "========================================================"
			echo "Building $SERVER:$TAG$SRVEXT$JVMEXT image..."
			echo "========================================================"
			DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
			FROM=`grep '^FROM' Dockerfile-$TAG | awk '{ print $2 }'`
			sudo docker pull $FROM
			sudo docker build --network host -f Dockerfile-$TAG -t $SERVER:$TAG$SRVEXT$JVMEXT --build-arg date=$DATE --build-arg jvm=${JVM} .
			echo "Done"
		done
	done
done
rm -fr tomcat

echo ""
for SRV in $SRVS
do
	SRVEXT=""
	[ $SRV != "tomcat" ] && SRVEXT="-$SRV"

	for TAG in $TAGS
	do
		JVMS="latest"
		[ $TAG = "centos" -o $TAG = "centos8" ] && JVMS="latest 11 1.8.0"

		for JVM in $JVMS
		do
			JVMEXT=""
			[ $JVM != "latest" ] && JVMEXT="-openjdk-$JVM"

			echo "-- $SERVER:$TAG$SRVEXT$JVMEXT ------------------"
			echo "sudo docker run -it --rm -p 9090:8080 -p 9443:8443 $SERVER:$TAG$SRVEXT$JVMEXT"
			echo "sudo docker push $SERVER:$TAG$SRVEXT$JVMEXT"
			if [ $TAG = "centos" -a $SRV = "tomcat" -a $JVM = "latest" ]
			then
				echo "sudo docker tag $SERVER:$TAG $SERVER:latest"
				echo "sudo docker push $SERVER:latest"
				echo "sudo docker rmi $SERVER:latest"
			fi
			echo ""
		done
	done
done

rm -f $LOCK
exit 0
