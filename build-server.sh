#!/bin/bash

LOCK=/tmp/$(basename $0 .sh).lck

exit_with () {
	[ "$2" != "" ] && echo -e $2 >&2
	rm -f $LOCK
	exit ${1:-0}
}

[ "$1" = "--help" ] && exit_with 1 "\nUsage: \e[1m$(basename $0)\e[0m [--delete] [\"<variants(s), defaults to all>\" [\"<server(s)>, defaults to tomcat>\"]\n"

trap "rm -f $LOCK" TERM INT QUIT HUP
[ -f $LOCK ] && exit_with 2 "A build process is in process since $(cat $LOCK)"
date > $LOCK

DEL=0
if [ "$1" = "--delete" ]
then
	DEL=1
	shift
fi

echo ""
echo "--------------------------------------------------------"

TAGS=${1:-centos-base centos centos-temurin centos-jvmless centos8-base centos8 centos8-temurin centos8-jvmless adoptium alpine alpine-temurin alpine-temurin-jre rockylinux almalinux devel}
echo "Variants(s) = $TAGS"

# Servers
#SRVS=${2:-tomcat tomee}
SRVS=${2:-tomcat}
echo "Server(s) = $SRVS"

# JVMs
JVMS_CENTOS="11 1.8.0"
JVMS_CENTOS8="17 11 1.8.0"
JVMS_CENTOS_TEMURIN="17 17-jre 11 11-jre 8 8-jre"
JVMS_ADOPTIUM="17 11"

# Variant/server/JVM for the :latest tag
TAG_LATEST="centos-temurin"
SRV_LATEST="tomcat"
JVM_LATEST="17"

echo "--------------------------------------------------------"
echo ""

SERVER=simplicite/server

for SRV in $SRVS
do
	if [ -d $SRV.git ]
	then
		echo "Updating $SRV.git"
		cd $SRV.git
		git config remote.origin.fetch 'refs/heads/*:refs/heads/*' || exit_with 3 "Unable to configure fetch origin in $SRV.git"
		git fetch --verbose --all --force || exit_with 4 "Unable to fetch in $SRV.git"
		cd ..
		echo "Done"

		echo "Checkouting $SRV as tomcat..."
		rm -fr tomcat
		mkdir tomcat
		git --work-tree=tomcat --git-dir=$SRV.git checkout -f master || exit_with 5 "Unable to checkout master branch from $SRV.git"
		rm -f tomcat/.project tomcat/.git* tomcat/README.md tomcat/*.bat tomcat/bin/*.bat tomcat/bin/*.exe tomcat/bin/*.dll
		echo "Done"
	elif [ -d $SRV ]
	then
		echo "Copying $SRV as tomcat..."
		rm -fr tomcat
		cp -r $SRV tomcat
		echo "Done"
	else
		rm -f $LOCK
		exit_with 6 "Unknown server $SRV, aborting"
	fi

	chmod +x run*.sh tomcat/*.sh tomcat/bin/*.sh
	for DIR in work work/Catalina conf/Catalina temp logs webapps
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
		[ $TAG = "centos" ] && JVMS=$JVMS_CENTOS
		[ $TAG = "centos8" ] && JVMS=$JVMS_CENTOS8
		[ $TAG = "centos-temurin" -o $TAG = "centos8-temurin" ] && JVMS=$JVMS_CENTOS_TEMURIN
		[ $TAG = "adoptium" ] && JVMS=$JVMS_ADOPTIUM

		for JVM in $JVMS
		do
			JVMEXT=""
			if [ $JVM != "latest" ]
			then
				if [ $TAG = "alpine-temurin" -o $TAG = "centos-temurin" -o $TAG = "centos-jvmless" -o $TAG = "centos8-temurin" -o $TAG = "centos8-jvmless" -o $TAG = "adoptium" -o $TAG = "rockylinux"  -o $TAG = "almalinux" ]
				then
					JVMEXT="-$JVM"
				else
					JVMEXT="-openjdk-$JVM"
				fi
			fi

			if [ $TAG != "centos" -a $TAG != "centos8" -a $TAG != "centos-temurin" -a $TAG != "centos-jvmless" -a $TAG != "centos8-temurin" -a $TAG != "centos8-jvmless" -a $TAG != "devel" ]
			then
				FROM=$(grep '^FROM' Dockerfile-$TAG | awk '{ print $2 }' | sed "s/.{jvm}/$JVM/")
				echo "Pulling image: $FROM"
				docker pull $FROM
				echo "Done"
			fi

			if [ $TAG = "centos" -o $TAG = "centos8" ]
			then
				echo "========================================================"
				echo "Building $SERVER:$TAG$SRVEXT$JVMEXT-jre image..."
				echo "========================================================"
				DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
				[ $DEL = 1 ] && docker rmi $SERVER:$TAG$SRVEXT$JVMEXT-jre
				docker build --network host -f Dockerfile-$TAG-jre -t $SERVER:$TAG$SRVEXT$JVMEXT-jre --build-arg date="$DATE" --build-arg jvm="$JVM" .
				echo "Done"
			fi

			echo "========================================================"
			echo "Building $SERVER:$TAG$SRVEXT$JVMEXT image..."
			echo "========================================================"
			DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
			[ $DEL = 1 ] && docker rmi $SERVER:$TAG$SRVEXT$JVMEXT
			docker build --network host -f Dockerfile-$TAG -t $SERVER:$TAG$SRVEXT$JVMEXT --build-arg date="$DATE" --build-arg variant="$JVMEXT" --build-arg jvm="$JVM" .
			echo "Done"
			if [ $TAG = $TAG_LATEST -a $SRV = $SRV_LATEST -a $JVM = $JVM_LATEST ]
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
		[ $TAG = "centos" ] && JVMS=$JVMS_CENTOS
		[ $TAG = "centos8" ] && JVMS=$JVMS_CENTOS8
		[ $TAG = "centos-temurin" -o $TAG = "centos8-temurin" ] && JVMS=$JVMS_CENTOS_TEMURIN
		[ $TAG = "adoptium" ] && JVMS=$JVMS_ADOPTIUM

		for JVM in $JVMS
		do
			JVMEXT=""
			if [ $JVM != "latest" ]
			then
				if [ $TAG = "alpine-temurin" -o $TAG = "centos-temurin" -o $TAG = "centos-jvmless" -o $TAG = "centos8-temurin" -o $TAG = "centos8-jvmless" -o $TAG = "adoptium" -o $TAG = "rockylinux" -o $TAG = "almalinux" ]
				then
					JVMEXT="-$JVM"
				else
					JVMEXT="-openjdk-$JVM"
				fi
			fi

			if [ $TAG != "centos-base" -a $TAG != "centos-jvmless"  -a $TAG != "centos8-base" -a $TAG != "centos8-jvmless" ]
			then
				echo "-- $SERVER:$TAG$SRVEXT$JVMEXT ------------------"
				echo ""
				if [ $TAG = "centos" -o $TAG = "centos8" ]
				then
					echo "docker run -it --memory=128m -p 127.0.0.1:8080:8080 -p 127.0.0.1:8443:8443 --name simplicite $SERVER:$TAG$SRVEXT$JVMEXT-jre"
				fi
				echo "docker run -it --rm --memory=128m -p 127.0.0.1:8080:8080 -p 127.0.0.1:8443:8443 --name=simplicite $SERVER:$TAG$SRVEXT$JVMEXT"
			fi
			echo ""
		done
	done
done

exit_with
