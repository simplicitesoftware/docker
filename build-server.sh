#!/bin/bash

exit_with () {
	[ "$2" != "" ] && echo -e $2 >&2
	rm -f $LOCK
	exit ${1:-0}
}

[ "$1" = "--help" ] && exit_with 1 "\nUsage: \e[1m$(basename $0)\e[0m [--delete] [--no-cache] [\"<variants(s), defaults to all>\" [\"<server(s)>, defaults to tomcat>\"]\n"

LOCK=/tmp/$(basename $0 .sh).lck
if [ -f $LOCK ]
then
	echo -e "A build process is in process since $(cat $LOCK)" >&2
	exit 2
fi
date > $LOCK

trap "rm -f $LOCK" TERM INT QUIT HUP

DEL=0
if [ "$1" = "--delete" ]
then
	DEL=1
	shift
fi

NOCACHE=""
if [ "$1" = "--no-cache" ]
then
	NOCACHE=$1
	shift
fi

echo ""
echo "--------------------------------------------------------"

#TAGS=${1:-centos-base centos centos-jvmless almalinux8-base almalinux8 almalinux8-jvmless almalinux9-base almalinux9 almalinux9-jvmless alpine-base alpine eclipse-temurin devel}
TAGS=${1:-almalinux9-base almalinux9 almalinux9-jvmless alpine-base alpine eclipse-temurin devel}
echo "Variants(s) = $TAGS"

# Servers
#SRVS=${2:-tomcat tomee}
SRVS=${2:-tomcat}
echo "Server(s) = $SRVS"

BRANCH=master

# JVMs (note: only the latest JVM for ALPINE)
JVMS_CENTOS="21 17 11"
JVMS_ALMALINUX="21 17"
JVMS_ALPINE="21"
JVMS_ECLIPSE_TEMURIN="21 17 11"

# Variant/server/JVM for the :latest tag
TAG_LATEST="almalinux9"
SRV_LATEST="tomcat"
JVM_LATEST="21"

echo "--------------------------------------------------------"
echo ""

SERVER=registry.simplicite.io/server

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

		echo "Checkouting $SRV (branch $BRANCH) as 'tomcat' dir..."
		rm -fr tomcat
		mkdir tomcat
		git --work-tree=tomcat --git-dir=$SRV.git checkout -f $BRANCH || exit_with 5 "Unable to checkout $BRANCH branch from $SRV.git"
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
		JVMS=""
		[ $TAG = "centos" ] && JVMS=$JVMS_CENTOS
		[ $TAG = "almalinux8" -o $TAG = "almalinux9" ] && JVMS=$JVMS_ALMALINUX
		[ $TAG = "alpine" ] && JVMS=$JVMS_ALPINE
		[ $TAG = "eclipse-temurin" ] && JVMS=$JVMS_ECLIPSE_TEMURIN

		if [ "$JVMS" = "" ]
		then
			if [ $TAG != "devel" ]
			then
				FROM=$(grep '^FROM' Dockerfile-$TAG | awk '{ print $2 }')
				echo "Pulling image: $FROM"
				docker pull $FROM
				echo "Done"
			fi

			echo "========================================================"
			echo "Building $SERVER:$TAG$SRVEXT image..."
			echo "========================================================"
			[ $DEL = 1 ] && docker rmi $SERVER:$TAG$SRVEXT > /dev/null 2>&1
			docker build $NOCACHE --network host -f Dockerfile-$TAG -t $SERVER:$TAG$SRVEXT --build-arg date="=$(date -u +s'%Y-%m-%dT%H:%M:%SZ')" .
			echo "Done"
		else
			for JVM in $JVMS
			do
				[ $TAG = "alpine" ] && TAGEXT="" || TAGEXT="-$JVM"

				if [ $TAG = "centos" -o $TAG = "almalinux8" -o $TAG = "almalinux9" -o $TAG = "alpine" ]
				then
					echo "========================================================"
					echo "Building $SERVER:$TAG$TAGEXT-jre$SRVEXT image..."
					echo "========================================================"
					[ $DEL = 1 ] && docker rmi $SERVER:$TAG$TAGEXT-jre$SRVEXT > /dev/null 2>&1
					docker build $NOCACHE --network host -f Dockerfile-$TAG -t $SERVER:$TAG$TAGEXT-jre$SRVEXT --build-arg date="$(date -u +s'%Y-%m-%dT%H:%M:%SZ')" --build-arg jvm="$JVM-jre" .
					echo "Done"
				fi

				echo "========================================================"
				echo "Building $SERVER:$TAG$TAGEXT$SRVEXT image..."
				echo "========================================================"
				[ $DEL = 1 ] && docker rmi $SERVER:$TAG$TAGEXT$SRVEXT > /dev/null 2>&1
				docker build $NOCACHE --network host -f Dockerfile-$TAG -t $SERVER:$TAG$TAGEXT$SRVEXT --build-arg date="$(date -u +s'%Y-%m-%dT%H:%M:%SZ')" --build-arg jvm="$JVM" .
				echo "Done"

				[ $TAG = $TAG_LATEST -a $SRV = $SRV_LATEST -a $JVM = $JVM_LATEST ] && docker tag $SERVER:$TAG$TAGEXT$SRVEXT $SERVER:latest
			done
		fi
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
		JVMS=""
		[ $TAG = "centos" ] && JVMS=$JVMS_CENTOS
		[ $TAG = "almalinux8" -o $TAG = "almalinux9" ] && JVMS=$JVMS_ALMALINUX
		[ $TAG = "alpine" ] && JVMS=$JVMS_ALPINE
		[ $TAG = "eclipse-temurin" ] && JVMS=$JVMS_ECLIPSE_TEMURIN

		for JVM in $JVMS
		do
			[ $TAG = "alpine" ] && TAGEXT="" || TAGEXT="-$JVM"

			if [ $TAG = "centos" -o $TAG = "almalinux8" -o $TAG = "almalinux9" -o $TAG = "alpine" ]
			then
				echo "docker run -it --rm --memory=128m -p 127.0.0.1:8080:8080 -p 127.0.0.1:8443:8443 --name simplicite $SERVER:$TAG$TAGEXT-jre$SRVEXT"
			fi
			echo "docker run -it --rm --memory=128m -p 127.0.0.1:8080:8080 -p 127.0.0.1:8443:8443 --name=simplicite $SERVER:$TAG$TAGEXT$SRVEXT"
			echo ""
		done
	done
done

exit_with
