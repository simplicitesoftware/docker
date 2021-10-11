#!/bin/bash

if [ "$1" = "" -o "$1" = "--help" ]
then
	echo "Usage: `basename $0` [--delete] 3.0|3.1|3.2|4.0-latest[-light]|5-<alpha|beta|latest>[-light]|<4.0|5>-devel [<server image tag(s)> [<platform Git tag (only applicable to 5-latest and 5-latest-light>]]" >&2
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

LATEST=5
GITTAG=

if [ "$1" = "3.0" ]
then
	VERSION=3.0
	BRANCH=master
	TAGS=${2:-centos-openjdk-1.8.0}
	SRVS=tomcat
	PFTAG=$1
	CHECKOUT=$BRANCH
elif [ "$1" = "3.1" ]
then
	VERSION=3.1
	BRANCH=master
	TAGS=${2:-centos-openjdk-1.8.0}
	SRVS=tomcat
	PFTAG=$1
	CHECKOUT=$BRANCH
elif [ "$1" = "3.2" ]
then
	VERSION=3.2
	BRANCH=master
	TAGS=${2:-centos-openjdk-1.8.0}
	SRVS=tomcat
	PFTAG=$1
	CHECKOUT=$BRANCH
elif [ "$1" = "4.0" -o "$1" = "4.0-latest" ]
then
	VERSION=4.0
	BRANCH=release
	# ZZZ temporary
	#TAGS=${2:-centos centos-openjdk-11 centos-temurin-17 centos-temurin-11 adoptium-17 adoptium-11}
	TAGS=${2:-centos-openjdk-11 centos-temurin-17 centos-temurin-11 adoptium-17 adoptium-11}
	SRVS=tomcat
	PFTAG=$1
	CHECKOUT=$BRANCH
	GITTAG=$3
	if [ "$GITTAG" != "" ]
	then
		PFTAG=$GITTAG-light
		CHECKOUT=$GITTAG
	fi
elif [ "$1" = "4.0-light" -o "$1" = "4.0-latest-light" ]
then
	VERSION=4.0
	BRANCH=release-light
	# ZZZ temporary
	#TAGS=${2:-centos centos-openjdk-11 centos-openjdk-1.8.0 centos-temurin-17 centos-temurin-11 centos-temurin-8 adoptium-17 adoptium-11 adoptium-8}
	TAGS=${2:-centos-openjdk-11 centos-openjdk-1.8.0 centos-temurin-17 centos-temurin-11 centos-temurin-8 adoptium-17 adoptium-11 adoptium-8}
	SRVS=tomcat
	PFTAG=$1
	CHECKOUT=$BRANCH
	GITTAG=$3
	if [ "$GITTAG" != "" ]
	then
		PFTAG=$GITTAG-light
		CHECKOUT=$GITTAG
	fi
elif [ "$1" = "4.0-devel" ]
then
	VERSION=4.0
	BRANCH=master
	TAGS=devel
	SRVS=tomcat
	PFTAG=$1
	CHECKOUT=$BRANCH
	GITTAG=$3
	if [ "$GITTAG" != "" ]
	then
		PFTAG=$GITTAG-light
		CHECKOUT=$GITTAG
	fi
elif [ "$1" = "5-alpha" ]
then
	VERSION=5
	BRANCH=master
	# ZZZ temporary
	#TAGS=${2:-centos centos-temurin-17}
	TAGS=${2:-centos-temurin-17}
	SRVS=tomcat
	PFTAG=$1
	CHECKOUT=$BRANCH
elif [ "$1" = "5-alpha-light" ]
then
	VERSION=5
	BRANCH=master-light
	# ZZZ temporary
	#TAGS=${2:-centos centos-temurin-17}
	TAGS=${2:-centos-temurin-17}
	SRVS=tomcat
	PFTAG=$1
	CHECKOUT=$BRANCH
elif [ "$1" = "5-alpha-test" ]
then
	VERSION=5
	BRANCH=master
	TAGS=${2:-centos8 rockylinux alpine alpine-temurin}
	SRVS=tomcat
	PFTAG=$1
	CHECKOUT=$BRANCH
elif [ "$1" = "5-devel" ]
then
	VERSION=5
	BRANCH=master
	TAGS=devel
	SRVS=tomcat
	PFTAG=$1
	CHECKOUT=$BRANCH
	GITTAG=$3
	if [ "$GITTAG" != "" ]
	then
		PFTAG=$GITTAG-light
		CHECKOUT=$GITTAG
	fi
elif [ "$1" = "5-beta" ]
then
	VERSION=5
	BRANCH=prerelease
	# ZZZ temporary
	#TAGS=${2:-centos centos-temurin-17}
	TAGS=${2:-centos-temurin-17}
	SRVS=tomcat
	PFTAG=$1
	CHECKOUT=$BRANCH
elif [ "$1" = "5-beta-light" ]
then
	VERSION=5
	BRANCH=prerelease-light
	# ZZZ temporary
	#TAGS=${2:-centos centos-temurin-17}
	TAGS=${2:-centos-temurin-17}
	SRVS=tomcat
	PFTAG=$1
	CHECKOUT=$BRANCH
elif [ "$1" = "5-latest" -o "$1" = "5" ]
then
	VERSION=5
	BRANCH=release
	# ZZZ temporary
	#TAGS=${2:-centos centos-temurin-17 centos-openjdk-11 centos-temurin-11 adoptium-17 adoptium-11}
	TAGS=${2:-centos-temurin-17 centos-openjdk-11 centos-temurin-11 adoptium-17 adoptium-11}
	SRVS=tomcat
	PFTAG=$1
	CHECKOUT=$BRANCH
	GITTAG=$3
	if [ "$GITTAG" != "" ]
	then
		PFTAG=$GITTAG
		CHECKOUT=$GITTAG
	fi
elif [ "$1" = "5-latest-light" -o "$1" = "5-light" ]
then
	VERSION=5
	BRANCH=release-light
	# ZZZ temporary
	#TAGS=${2:-centos centos-temurin-17 centos-openjdk-11 centos-temurin-11 adoptium-17 adoptium-11}
	TAGS=${2:-centos-temurin-17 centos-openjdk-11 centos-temurin-11 adoptium-17 adoptium-11}
	SRVS=tomcat
	PFTAG=$1
	CHECKOUT=$BRANCH
	GITTAG=$3
	if [ "$GITTAG" != "" ]
	then
		PFTAG=$GITTAG-light
		CHECKOUT=$GITTAG
	fi
elif [ "$1" = "5.0" ]
then
	VERSION=5
	BRANCH=5.0
	TAGS=${2:-centos centos-temurin-17}
	SRVS=tomcat
	PFTAG=$1
	CHECKOUT=$BRANCH
elif [ "$1" = "5.0-light" ]
then
	VERSION=5
	BRANCH=5.0-light
	TAGS=${2:-centos centos-temurin-17}
	SRVS=tomcat
	PFTAG=$1
	CHECKOUT=$BRANCH
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
git fetch --verbose --all --force --tags
cd ..
echo "Done"

echo "Checkouting $TEMPLATE..."
rm -fr $TEMPLATE
mkdir $TEMPLATE
git --work-tree=$TEMPLATE --git-dir=$TEMPLATE.git checkout -f $CHECKOUT
chmod +x $TEMPLATE/tools/*.sh && \
echo "Done"

echo "Enabling console logging in $TEMPLATE..."
# Log4J version 1.x
LOG4J="$TEMPLATE/app/WEB-INF/classes/log4j.xml"
[ -f $LOG4J ] && sed -i 's/<!-- appender-ref ref="SIMPLICITE-CONSOLE"\/ -->/<appender-ref ref="SIMPLICITE-CONSOLE"\/>/' $LOG4J
# Log4J version 2.x
LOG4J2="$TEMPLATE/app/WEB-INF/classes/log4j2.xml"
[ -f $LOG4J2 ] && sed -i 's/<!-- AppenderRef ref="SIMPLICITE-CONSOLE"\/ -->/<AppenderRef ref="SIMPLICITE-CONSOLE"\/>/' $LOG4J2
echo "Done"

grep -q '<!-- database -->' $TEMPLATE/app/META-INF/context.xml
if [ $? = 0 ]
then
	echo "Removing old databases resources..."
	for DB in hsqldb mysql postgresql oracle mssql
	do
		sed -i "/<!-- $DB --></,/><!-- $DB -->/d" $TEMPLATE/app/META-INF/context.xml
	done
	sed -i "s/<!-- database --><!-- /<!-- database --></;s/ --><!-- database -->/><!-- database -->/" $TEMPLATE/app/META-INF/context.xml
	echo "Done"
fi

if [ -x $TEMPLATE/tools/convert-oracle.sh ]
then
	echo "Generating Oracle script in $TEMPLATE..."
	$TEMPLATE/tools/convert-oracle.sh simplicite $TEMPLATE/app/WEB-INF/db/simplicite.script
	echo "Done"
fi

if [ -x $TEMPLATE/tools/convert-mssql.sh ]
then
	echo "Generating SQLServer script in $TEMPLATE..."
	$TEMPLATE/tools/convert-mssql.sh simplicite $TEMPLATE/app/WEB-INF/db/simplicite.script
	echo "Done"
fi

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
		[ $TAG != "centos" -a $TAG != "devel" ] && EXT="-`echo $TAG | sed 's/centos-//'`"
		[ $SRV != "tomcat" ] && EXT="$EXT-$SRV"
		echo "========================================================"
		echo "Building $PLATFORM:$PFTAG$EXT image from $SERVER:$TAG..."
		echo "========================================================"
		DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
		[ $DEL = 1 ] && docker rmi $PLATFORM:$PFTAG$EXT
		docker build --network host -f Dockerfile-platform --build-arg date=$DATE --build-arg tag=$TAG --build-arg version=$VERSION --build-arg branch=$BRANCH --build-arg patchlevel=$PATCHLEVEL --build-arg revision=$REVISION --build-arg commitid=$COMMITID --build-arg template=$TEMPLATE -t $PLATFORM:$PFTAG$EXT .
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
		[ $TAG != "centos" -a $TAG != "devel" ] && EXT="-`echo $TAG | sed 's/centos-//'`"
		[ $SRV != "tomcat" ] && EXT="$EXT-$SRV"
		echo "-- $PLATFORM:$PFTAG$EXT ------------------"
		echo ""
		echo "docker run -it --rm -p 127.0.0.1:8080:8080 -p 127.0.0.1:8443:8443 --name=simplicite $PLATFORM:$PFTAG$EXT"
		echo "docker run -it --rm -p 127.0.0.1:8080:8080 -p 127.0.0.1:8443:8443 --name=simplicite -e DB_SETUP=true -e DB_VENDOR=mysql -e DB_HOST=$IP -e DB_PORT=3306 -e DB_USER=$DB -e DB_PASSWORD=$DB -e DB_NAME=$DB $PLATFORM:$PFTAG$EXT"
		echo "docker run -it --rm -p 127.0.0.1:8080:8080 -p 127.0.0.1:8443:8443 --name=simplicite -e DB_SETUP=true -e DB_VENDOR=postgresql -e DB_HOST=$IP -e DB_PORT=5432 -e DB_USER=$DB -e DB_PASSWORD=$DB -e DB_NAME=$DB $PLATFORM:$PFTAG$EXT"
		echo ""
	done
done

rm -f $LOCK
exit 0
