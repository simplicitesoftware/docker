#!/bin/bash

exit_with () {
	[ "$2" != "" ] && echo -e $2 >&2
	rm -f $LOCK
	exit ${1:-0}
}

[ "$1" = "" -o "$1" = "--help" ] && exit_with 1 "\nUsage: \e[1m$(basename $0)\e[0m [--delete] 3.0|3.1|3.2|4.0[-light]|5-<preview|latest|devel>[-light]|6-alpha[-light] [<server image tag(s)> [<platform Git tag (only applicable to 5-latest and 5-latest-light>]]\n"

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

LATEST=5
GITTAG=
CHECKOUT=

if [ "$1" = "3.0" ]
then
	VERSION=3.0
	BRANCH=master
	TAGS=${2:-centos-adoptium-8}
	SRVS=tomcat
	PFTAG=$1
elif [ "$1" = "3.1" ]
then
	VERSION=3.1
	BRANCH=master
	TAGS=${2:-centos-adoptium-8}
	SRVS=tomcat
	PFTAG=$1
elif [ "$1" = "3.2" ]
then
	VERSION=3.2
	BRANCH=master
	TAGS=${2:-centos-adoptium-8}
	SRVS=tomcat
	PFTAG=$1
elif [ "$1" = "4.0" ]
then
	VERSION=4.0
	BRANCH=release
	TAGS=${2:-centos-adoptium-17}
	SRVS=tomcat
	PFTAG=$1
	GITTAG=$3
	if [ "$GITTAG" != "" ]
	then
		PFTAG=$GITTAG-light
		CHECKOUT=$GITTAG
	fi
elif [ "$1" = "4.0-light" ]
then
	VERSION=4.0
	BRANCH=release-light
	TAGS=${2:-centos-adoptium-17}
	SRVS=tomcat
	PFTAG=$1
	GITTAG=$3
	if [ "$GITTAG" != "" ]
	then
		PFTAG=$GITTAG-light
		CHECKOUT=$GITTAG
	fi
elif [ "$1" = "5-preview" ]
then
	VERSION=5
	BRANCH=prerelease
	TAGS=${2:-centos-adoptium-17}
	SRVS=tomcat
	PFTAG=$1
elif [ "$1" = "5-preview-light" ]
then
	VERSION=5
	BRANCH=prerelease-light
	TAGS=${2:-centos-adoptium-17}
	SRVS=tomcat
	PFTAG=$1
elif [ "$1" = "5-latest" -o "$1" = "5" ]
then
	VERSION=5
	BRANCH=release
	TAGS=${2:-centos-adoptium-17 centos-adoptium-17-jre centos-jvmless alpine}
	SRVS=tomcat
	PFTAG=$1
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
	TAGS=${2:-centos-adoptium-17 centos-adoptium-17-jre centos-jvmless alpine}
	SRVS=tomcat
	PFTAG=$1
	GITTAG=$3
	if [ "$GITTAG" != "" ]
	then
		PFTAG=$GITTAG-light
		CHECKOUT=$GITTAG
	fi
elif [ "$1" = "5-latest-test" ]
then
	VERSION=5
	BRANCH=release
	TAGS=${2:-almalinux8-21 almalinux9-21}
	SRVS=tomcat
	PFTAG=$1
elif [ "$1" = "5-devel" ]
then
	VERSION=5
	BRANCH=release
	TAGS=devel
	SRVS=tomcat
	PFTAG=$1
	GITTAG=$3
elif [ "$1" = "5.0" -o "$1" = "5.0-light" -o "$1" = "5.1" -o "$1" = "5.1-light" -o "$1" = "5.2" -o "$1" = "5.2-light" ]
then
	VERSION=5
	BRANCH=$1
	TAGS=${2:-centos-adoptium-17}
	SRVS=tomcat
	PFTAG=$1
elif [ "$1" = "6-alpha" ]
then
	VERSION=6
	BRANCH=6.0
	#TAGS=${2:-almalinux8-17 almalinux8-17-jre almalinux8-jvmless alpine}
	TAGS=${2:-almalinux8-17 alpine}
	SRVS=tomcat
	PFTAG=$1
elif [ "$1" = "6-alpha-light" ]
then
	VERSION=6
	BRANCH=6.0-light
	#TAGS=${2:-almalinux8-17 almalinux8-17-jre almalinux8-jvmless alpine}
	TAGS=${2:-almalinux8-17 alpine}
	SRVS=tomcat
	PFTAG=$1
else
	rm -f $LOCK
	exit_with 3 "Unknown variant: $1"
fi
# TODO: add 6-beta and 6-release

REGISTRY=registry.simplicite.io
SERVER=$REGISTRY/server
PLATFORM=$REGISTRY/platform
TEMPLATE=template-$VERSION

if [ ! -d $TEMPLATE.git ]
then
	rm -f $LOCK
	exit_with 4 "Git repository for template $TEMPLATE not cloned: git clone --bare <path to $TEMPLATE>.git"
fi

echo "Updating $TEMPLATE"
cd $TEMPLATE.git
git config remote.origin.fetch 'refs/heads/*:refs/heads/*' || exit_with 5 "Unable to configure fetch origin in $TEMPLATE.git"
git fetch --verbose --all --force || exit_with 5 "Unable to fetch in $TEMPLATE.git"
git fetch --verbose --all --force --tags || exit_with 6 "Unable to fetch tags in $TEMPLATE.git"
cd ..
echo "Done"

echo "Checkouting $TEMPLATE..."
rm -fr $TEMPLATE
mkdir $TEMPLATE
git --work-tree=$TEMPLATE --git-dir=$TEMPLATE.git checkout -f ${CHECKOUT:-$BRANCH} || exit_with 5 "Unable to checkout ${CHECKOUT:-$BRANCH} branch from $TEMPLATE.git"
chmod +x $TEMPLATE/tools/*.sh && \
echo "Done"

echo "Enabling console logging by default in $TEMPLATE..."
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
VERSION=$(grep platform.version $PROPS | awk -F= '{print $2}')
PATCHLEVEL=$(grep platform.patchlevel $PROPS | awk -F= '{print $2}')
REVISION=$(grep platform.revision $PROPS | awk -F= '{print $2}')
COMMITID=$(grep platform.commitid $PROPS | awk -F= '{print $2}')
[ "$COMMITID" = "" ] && COMMITID=$REVISION

for SRV in $SRVS
do
	for TAG in $TAGS
	do
		EXT=""
		[ $TAG != "devel" ] && EXT="-$TAG"
		[ $SRV != "tomcat" ] && EXT="$EXT-$SRV"
		echo "========================================================"
		echo "Building $PLATFORM:$PFTAG$EXT image from $SERVER:$TAG..."
		echo "========================================================"
		DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
		DESTPATH="tomcat"
		[ $TAG = "jetty" ] && DESTPATH="jetty/default"
		[ $DEL = 1 ] && docker rmi $PLATFORM:$PFTAG$EXT
		docker build --network host -f Dockerfile-platform --build-arg date=$DATE --build-arg tag=$TAG --build-arg version=$VERSION --build-arg patchlevel=$PATCHLEVEL --build-arg revision=$REVISION --build-arg commitid=$COMMITID --build-arg template=$TEMPLATE --build-arg destpath=$DESTPATH -t $PLATFORM:$PFTAG$EXT .
		echo "Done"
	done
done

echo "Removing $TEMPLATE..."
rm -fr $TEMPLATE
echo "Done"

echo ""
DB=docker
IP=$(ifconfig eth0 | grep 'inet ' | awk '{print $2}')
for SRV in $SRVS
do
	for TAG in $TAGS
	do
		EXT=""
		[ $TAG != "devel" ] && EXT="-$TAG"
		[ $SRV != "tomcat" ] && EXT="$EXT-$SRV"
		echo "-- $PLATFORM:$PFTAG$EXT ------------------"
		echo ""
		echo "docker run -it --rm -p 127.0.0.1:8080:8080 -p 127.0.0.1:8443:8443 --name=simplicite $PLATFORM:$PFTAG$EXT"
		echo "docker run -it --rm -p 127.0.0.1:8080:8080 -p 127.0.0.1:8443:8443 --name=simplicite -e DB_SETUP=true -e DB_VENDOR=mysql -e DB_HOST=$IP -e DB_PORT=3306 -e DB_USER=$DB -e DB_PASSWORD=$DB -e DB_NAME=$DB $PLATFORM:$PFTAG$EXT"
		echo "docker run -it --rm -p 127.0.0.1:8080:8080 -p 127.0.0.1:8443:8443 --name=simplicite -e DB_SETUP=true -e DB_VENDOR=postgresql -e DB_HOST=$IP -e DB_PORT=5432 -e DB_USER=$DB -e DB_PASSWORD=$DB -e DB_NAME=$DB $PLATFORM:$PFTAG$EXT"
		echo ""
	done
done

exit_with
