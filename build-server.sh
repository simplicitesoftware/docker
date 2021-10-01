#!/bin/bash

if [ "$1" = "--help" ]
then
	echo "Usage: `basename $0` [--delete] [\"<variants(s), defaults to all>\" [\"<server(s)>, defaults to tomcat]\"]" >&2
	exit 1
fi

DEL=0
if [ "$1" = "--delete" ]
then
	DEL=1
	shift
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

TAGS=${1:-alpine centos-base centos centos8-base centos8 devel adoptopenjdk temurin openjdk openjdkslim}
echo "Variants(s) = $TAGS"

#SRVS=${2:-tomcat tomee}
SRVS=${2:-tomcat}
echo "Server(s) = $SRVS"

JVMS_CENTOS="latest 11 1.8.0"
JVMS_ADOPTOPENJDK="openjdk16 openjdk11 openjdk8"
JVMS_TEMURIN="11 17"
JVMS_OPENJDK="17"

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
		[ $TAG = "temurin" ] && JVMS=$JVMS_TEMURIN
		[ $TAG = "openjdk" -o $TAG = "openjdkslim" ] && JVMS=$JVMS_OPENJDK

		for JVM in $JVMS
		do
			JVMEXT=""
			if [ $JVM != "latest" ]
			then
				if [ $TAG = "adoptopenjdk" -o $TAG = "temurin" -o $TAG = "openjdk" -o $TAG = "openjdkslim" ]
				then
					JVMEXT="-$JVM"
				else
					JVMEXT="-openjdk-$JVM"
				fi
			fi

			if [ $TAG != "centos" -a $TAG != "centos8" -a $TAG != "devel" ]
			then
				FROM=`grep '^FROM' Dockerfile-$TAG | awk '{ print $2 }' | sed "s/.{jvm}/$JVM/"`
				echo "Pulling image: $FROM"
				docker pull $FROM
				echo "Done"
			fi

			if [ $TAG = "centos" -o $TAG = "centos8" ]
			then
				echo "========================================================"
				echo "Building $SERVER:$TAG$SRVEXT$JVMEXT-jre image..."
				echo "========================================================"
				DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
				[ $DEL = 1 ] && docker rmi $SERVER:$TAG$SRVEXT$JVMEXT-jre
				docker build --network host -f Dockerfile-$TAG-jre -t $SERVER:$TAG$SRVEXT$JVMEXT-jre --build-arg date="$DATE" --build-arg jvm="$JVM" .
				echo "Done"
			fi

			echo "========================================================"
			echo "Building $SERVER:$TAG$SRVEXT$JVMEXT image..."
			echo "========================================================"
			DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
			[ $DEL = 1 ] && docker rmi $SERVER:$TAG$SRVEXT$JVMEXT
			docker build --network host -f Dockerfile-$TAG -t $SERVER:$TAG$SRVEXT$JVMEXT --build-arg date="$DATE" --build-arg variant="$JVMEXT" --build-arg jvm="$JVM" .
			echo "Done"
			if [ $TAG = "centos" -a $SRV = "tomcat" -a $JVM = "latest" ]
			then
				docker tag $SERVER:$TAG$SRVEXT$JVMEXT $SERVER:latest
			fi
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
		[ $TAG = "temurin" ] && JVMS=$JVMS_TEMURIN
		[ $TAG = "openjdk" -o $TAG = "openjdkslim" ] && JVMS=$JVMS_OPENJDK

		for JVM in $JVMS
		do
			JVMEXT=""
			if [ $JVM != "latest" ]
			then
				if [ $TAG = "adoptopenjdk" -o $TAG = "temurin" -o $TAG = "openjdk" -o $TAG = "openjdkslim" ]
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
					echo "docker run -it --memory=128m -p 127.0.0.1:8080:8080 -p 127.0.0.1:8443:8443 --name simplicite $SERVER:$TAG$SRVEXT$JVMEXT-jre"
				fi
				echo "docker run -it --rm --memory=128m -p 127.0.0.1:8080:8080 -p 127.0.0.1:8443:8443 --name=simplicite $SERVER:$TAG$SRVEXT$JVMEXT"
				echo ""
				if [ $TAG = "centos" -o $TAG = "centos8" ]
				then
					echo "docker push $SERVER:$TAG$SRVEXT$JVMEXT-jre"
				fi
				echo "docker push $SERVER:$TAG$SRVEXT$JVMEXT"
				if [ $TAG = "centos" -a $SRV = "tomcat" -a $JVM = "latest" ]
				then
					echo "docker push $SERVER:latest"
				fi
			fi
			echo ""
		done
	done
done

rm -f $LOCK
exit 0
