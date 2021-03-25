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

TAGS=${1:-alpine centos-base centos centos8-base centos8 devel adoptopenjdk}
echo "Variants(s) = $TAGS"

#SRVS=${2:-tomcat tomee}
SRVS=${2:-tomcat}
echo "Server(s) = $SRVS"

JVMS_CENTOS="latest 11 1.8.0"
JVMS_ADOPTOPENJDK="openjdk15 openjdk11"

echo "--------------------------------------------------------"
echo ""

SERVER=simplicite/server

for SRV in $SRVS
do
	if [ -d $SRV.git ]
	then
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
	elif [ -d $SRV ]
	then
		echo "Copying $SRV as tomcat..."
		rm -fr tomcat
		cp -r $SRV tomcat
		echo "Done"
	else
		echo "Unknown server $SRV, aborting" >&2
		rm -f $LOCK
		exit 3
	fi

	chmod +x tomcat/*.sh tomcat/bin/*.sh
	for DIR in work work/Catalina conf/Cataline temp logs webapps
	do
		[ ! -d tomcat/$DIR ] && mkdir tomcat/$DIR
	done
	echo 'CATALINA_PID="$CATALINA_BASE/work/catalina.pid"' > tomcat/bin/setenv.sh

	sed -i 's/<!-- SSL Connector/<Connector/;s/Connector SSL -->/Connector>/' tomcat/conf/server.xml
	sed -i 's/<!-- AJP Connector/<Connector/;s/Connector AJP -->/Connector>/' tomcat/conf/server.xml

	SRVEXT=""
	[ $SRV != "tomcat" ] && SRVEXT="-$SRV"

	for TAG in $TAGS
	do
		JVMS="latest"
		[ $TAG = "centos" -o $TAG = "centos8" ] && JVMS=$JVMS_CENTOS
		[ $TAG = "adoptopenjdk" ] && JVMS=$JVMS_ADOPTOPENJDK

		for JVM in $JVMS
		do
			JVMEXT=""
			if [ $JVM != "latest" ]
			then
				if [ $TAG = "adoptopenjdk" ]
				then
					JVMEXT="-$JVM"
				else
					JVMEXT="-openjdk-$JVM"
				fi
			fi

			if [ $TAG = "centos" -o $TAG = "centos8" ]
			then
				echo "========================================================"
				echo "Building $SERVER:$TAG$SRVEXT$JVMEXT-jre image..."
				echo "========================================================"
				DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
				sudo docker build --network host -f Dockerfile-$TAG-jre -t $SERVER:$TAG$SRVEXT$JVMEXT-jre --build-arg date="$DATE" --build-arg jvm="$JVM" .
				echo "Done"
			fi

			echo "========================================================"
			echo "Building $SERVER:$TAG$SRVEXT$JVMEXT image..."
			echo "========================================================"
			DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
			if [ $TAG != "centos" -a $TAG != "centos8" -a $TAG != "devel" ]
			then
				FROM=`grep '^FROM' Dockerfile-$TAG | awk '{ print $2 }'`
				sudo docker pull $FROM
			fi
			sudo docker build --network host -f Dockerfile-$TAG -t $SERVER:$TAG$SRVEXT$JVMEXT --build-arg date="$DATE" --build-arg variant="$JVMEXT" --build-arg jvm="$JVM" .
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
		[ $TAG = "centos" -o $TAG = "centos8" ] && JVMS=$JVMS_CENTOS
		[ $TAG = "adoptopenjdk" ] && JVMS=$JVMS_ADOPTOPENJDK

		for JVM in $JVMS
		do
			JVMEXT=""
			if [ $JVM != "latest" ]
			then
				if [ $TAG = "adoptopenjdk" ]
				then
					JVMEXT="-$JVM"
				else
					JVMEXT="-openjdk-$JVM"
				fi
			fi

			if [ $TAG != "centos-base" -a $TAG != "centos8-base" ]
			then
				echo "-- $SERVER:$TAG$SRVEXT$JVMEXT ------------------"
				echo ""
				if [ $TAG = "centos" -o $TAG = "centos8" ]
				then
					echo "sudo docker run -it --memory=128m -p 9090:8080 -p 9443:8443 --name simplicite $SERVER:$TAG$SRVEXT$JVMEXT-jre"
				fi
				echo "sudo docker run -it --rm --memory=128m -p 9090:8080 -p 9443:8443 --name=simplicite $SERVER:$TAG$SRVEXT$JVMEXT"
				echo ""
				if [ $TAG = "centos" -o $TAG = "centos8" ]
				then
					echo "sudo docker push $SERVER:$TAG$SRVEXT$JVMEXT-jre"
				fi
				echo "sudo docker push $SERVER:$TAG$SRVEXT$JVMEXT"
				if [ $TAG = "centos" -a $SRV = "tomcat" -a $JVM = "latest" ]
				then
					echo "sudo docker tag $SERVER:$TAG $SERVER:latest"
					echo "sudo docker push $SERVER:latest"
					echo "sudo docker rmi $SERVER:latest"
				fi
			fi
			echo ""
		done
	done
done

rm -f $LOCK
exit 0
