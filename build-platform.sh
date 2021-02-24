#!/bin/bash

if [ "$1" = "" -o "$1" = "--help" ]
then
	echo "Usage: `basename $0` 3.1|3.2|4.0-latest[-light]|5-<alpha|beta|latest>[-light]|<4.0|5>-devel [<server image tag(s)>]" >&2
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

LATEST=5

if [ "$1" = "3.1" ]
then
	VERSION=3.1
	BRANCH=master
	TAGS=${2:-centos}
	SRVS=tomcat
	PFTAG=$1
elif [ "$1" = "3.2" ]
then
	VERSION=3.2
	BRANCH=master
	TAGS=${2:-centos}
	SRVS=tomcat
	PFTAG=$1
elif [ "$1" = "4.0-latest" ]
then
	VERSION=4.0
	BRANCH=release
	TAGS=${2:-centos centos-jre centos-openjdk-11 centos-openjdk-11-jre adoptopenjdk-openjdk-15 adoptopenjdk-openjdk-11}
	SRVS=tomcat
	PFTAG=$1
elif [ "$1" = "4.0-latest-light" ]
then
	VERSION=4.0
	BRANCH=release-light
	TAGS=${2:-centos centos-jre centos-openjdk-11 centos-openjdk-11-jre centos-openjdk-1.8.0 adoptopenjdk-openjdk-15 adoptopenjdk-openjdk-11 adoptopenjdk-openjdk-8}
	SRVS=tomcat
	PFTAG=$1
elif [ "$1" = "4.0-devel" ]
then
	VERSION=4.0
	BRANCH=master
	TAGS=devel
	SRVS=tomcat
	PFTAG=$1
elif [ "$1" = "5-alpha" ]
then
	VERSION=5
	BRANCH=master
	TAGS=${2:-centos}
	SRVS=tomcat
	PFTAG=$1
elif [ "$1" = "5-alpha-light" ]
then
	VERSION=5
	BRANCH=master-light
	TAGS=${2:-centos}
	SRVS=tomcat
	PFTAG=$1
elif [ "$1" = "5-alpha-test" ]
then
	VERSION=5
	BRANCH=master
	TAGS=${2:-centos8}
	SRVS=tomcat
	PFTAG=$1
elif [ "$1" = "5-devel" ]
then
	VERSION=5
	BRANCH=master
	TAGS=devel
	SRVS=tomcat
	PFTAG=$1
elif [ "$1" = "5-beta" ]
then
	VERSION=5
	BRANCH=prerelease
	TAGS=${2:-centos}
	SRVS=tomcat
	PFTAG=$1
elif [ "$1" = "5-beta-light" ]
then
	VERSION=5
	BRANCH=prerelease-light
	TAGS=${2:-centos}
	SRVS=tomcat
	PFTAG=$1
elif [ "$1" = "5-latest" ]
then
	VERSION=5
	BRANCH=release
	TAGS=${2:-centos centos-jre centos-openjdk-11 centos-openjdk-11-jre adoptopenjdk-openjdk-15 adoptopenjdk-openjdk-11}
	SRVS=tomcat
	PFTAG=$1
elif [ "$1" = "5-latest-light" ]
then
	VERSION=5
	BRANCH=release-light
	TAGS=${2:-centos centos-jre centos-openjdk-11 centos-openjdk-11-jre adoptopenjdk-openjdk-15 adoptopenjdk-openjdk-11}
	SRVS=tomcat
	PFTAG=$1
else
	echo "Unknown variant: $1" >&2
	rm -f $LOCK
	exit 2
fi

SERVER=simplicite/server
PLATFORM=simplicite/platform
TEMPLATE=template-$VERSION

if [ ! -d $TEMPLATE.git ]
then
	echo "Git repository for template $TEMPLATE not cloned: git clone --bare <path to $TEMPLATE>.git" >&2
	rm -f $LOCK
	exit 3
fi

echo "Updating $TEMPLATE"
cd $TEMPLATE.git
git config remote.origin.fetch 'refs/heads/*:refs/heads/*'
git fetch --verbose --all --force
cd ..
echo "Done"

echo "Checkouting $TEMPLATE..."
rm -fr $TEMPLATE
mkdir $TEMPLATE
git --work-tree=$TEMPLATE --git-dir=$TEMPLATE.git checkout -f $BRANCH
chmod +x $TEMPLATE/tools/*.sh && \
echo "Done"

echo "Generating Oracle and SQLServer scripts in $TEMPLATE..."
$TEMPLATE/tools/convert-mssql.sh simplicite $TEMPLATE/app/WEB-INF/db/simplicite.script
$TEMPLATE/tools/convert-oracle.sh simplicite $TEMPLATE/app/WEB-INF/db/simplicite.script
echo "Done"

PROPS=$TEMPLATE/app/WEB-INF/classes/com/simplicite/globals.properties
VERSION=`grep platform.version $PROPS | awk -F= '{print $2}'`
PATCHLEVEL=`grep platform.patchlevel $PROPS | awk -F= '{print $2}'`
REVISION=`grep platform.revision $PROPS | awk -F= '{print $2}'`
COMMITID=`grep platform.commitid $PROPS | awk -F= '{print $2}'`
[ "$COMMITID" = "" ] && COMMITID=$REVISION

for SRV in $SRVS
do
	for TAG in $TAGS
	do
		EXT=""
		[ $TAG != "centos" ] && EXT="-`echo $TAG | sed 's/centos-//'`"
		[ $SRV != "tomcat" ] && EXT="$EXT-$SRV"
		echo "========================================================"
		echo "Building $PLATFORM:$PFTAG$EXT image from $SERVER:$TAG..."
		echo "========================================================"
		DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
		sudo docker build --network host -f Dockerfile-platform --build-arg date=$DATE --build-arg tag=$TAG --build-arg version=$VERSION --build-arg branch=$BRANCH --build-arg patchlevel=$PATCHLEVEL --build-arg revision=$REVISION --build-arg commitid=$COMMITID --build-arg template=$TEMPLATE -t $PLATFORM:$PFTAG$EXT .
		echo "Done"
	done
done

echo "Removing $TEMPLATE..."
rm -fr $TEMPLATE
echo "Done"

echo ""
DB=docker
IP=`ifconfig eth0 | grep 'inet ' | awk '{print $2}'`
for SRV in $SRVS
do
	for TAG in $TAGS
	do
		EXT=""
		[ $TAG != "centos" ] && EXT="-`echo $TAG | sed 's/centos-//'`"
		[ $SRV != "tomcat" ] && EXT="$EXT-$SRV"
		echo "-- $PLATFORM:$PFTAG$EXT ------------------"
		echo ""
		echo "sudo docker run -it --rm -p 9090:8080 -p 9443:8443 $PLATFORM:$PFTAG$EXT"
		echo "sudo docker run -it --rm -p 9090:8080 -p 9443:8443 -e DB_SETUP=true -e DB_VENDOR=mysql -e DB_HOST=$IP -e DB_PORT=3306 -e DB_USER=$DB -e DB_PASSWORD=$DB -e DB_NAME=$DB $PLATFORM:$PFTAG$EXT"
		echo "sudo docker run -it --rm -p 9090:8080 -p 9443:8443 -e DB_SETUP=true -e DB_VENDOR=postgresql -e DB_HOST=$IP -e DB_PORT=5432 -e DB_USER=$DB -e DB_PASSWORD=$DB -e DB_NAME=$DB $PLATFORM:$PFTAG$EXT"
		echo ""
		echo "sudo docker push $PLATFORM:$PFTAG$EXT"
		if [ $TAG = "centos" -a $SRV = "tomcat" ]
		then
			if [ $PFTAG = "4.0-latest" -o $PFTAG = "5-latest" ]
			then
				echo "sudo docker tag $PLATFORM:$PFTAG $PLATFORM:$VERSION"
				echo "sudo docker push $PLATFORM:$VERSION"
				if [ $PFTAG = "$LATEST-latest" ]
				then
					echo "sudo docker tag $PLATFORM:$PFTAG $PLATFORM:latest"
					echo "sudo docker push $PLATFORM:latest"
					echo "sudo docker rmi $PLATFORM:latest"
				fi
				echo "sudo docker rmi $PLATFORM:$VERSION"
			elif [ $PFTAG = "4.0-latest-light" -o $PFTAG = "5-latest-light" ]
			then
				echo "sudo docker tag $PLATFORM:$PFTAG $PLATFORM:$VERSION-light"
				echo "sudo docker push $PLATFORM:$VERSION-light"
				if [ $PFTAG = "$LATEST-latest-light" ]
				then
					echo "sudo docker tag $PLATFORM:$PFTAG $PLATFORM:latest-light"
					echo "sudo docker push $PLATFORM:latest-light"
					echo "sudo docker rmi $PLATFORM:latest-light"
				fi
				echo "sudo docker rmi $PLATFORM:$VERSION-light"
			fi
		fi
		echo "sudo docker rmi $PLATFORM:$PFTAG$EXT"
		echo ""
	done
done

rm -f $LOCK
exit 0
