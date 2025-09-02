#!/bin/bash

exit_with () {
	[ "$2" != "" ] && echo -e $2 >&2
	rm -f $LOCK
	exit ${1:-0}
}

[ "$1" = "" -o "$1" = "--help" ] && exit_with 1 "\nUsage: \e[1m$(basename $0)\e[0m [--delete] [--no-cache] 3.0|3.1|3.2|4.0[-light]|5-<latest|devel|preview>[-light]|6-<alpha|beta|latest|devel|preview>[-light]|7-preview [<server image tag(s)> [<platform Git tag (only applicable to 5-latest and 5-latest-light>]]\n"

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

GITTAG=
CHECKOUT=

DOCKERFILE_DEFAULT=Dockerfile-platform
DOCKERFILE=$DOCKERFILE_DEFAULT

SERVER=tomcat

if [ "$1" = "3.0" ]
then
	VERSION=3.0
	BRANCH=master
	TAGS=${2:-almalinux9-17}
	PFTAG=$1
elif [ "$1" = "3.1" ]
then
	VERSION=3.1
	BRANCH=master
	TAGS=${2:-almalinux9-17}
	PFTAG=$1
elif [ "$1" = "3.2" ]
then
	VERSION=3.2
	BRANCH=master
	TAGS=${2:-almalinux9-17}
	PFTAG=$1
elif [ "$1" = "4.0" ]
then
	VERSION=4.0
	BRANCH=release
	TAGS=${2:-almalinux9-17}
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
	TAGS=${2:-almalinux9-17}
	PFTAG=$1
	GITTAG=$3
	if [ "$GITTAG" != "" ]
	then
		PFTAG=$GITTAG-light
		CHECKOUT=$GITTAG
	fi
elif [ "$1" = "5-devel" ]
then
	VERSION=5
	# Release branch
	BRANCH=release
	TAGS=devel
	PFTAG=$1
elif [ "$1" = "5-preview" ]
then
	VERSION=5
	BRANCH=prerelease
	TAGS=${2:-almalinux9-17}
	PFTAG=$1
elif [ "$1" = "5-latest" -o "$1" = "5" ]
then
	VERSION=5
	BRANCH=release
	TAGS=${2:-almalinux9-17 almalinux9-17-jre almalinux9-jvmless alpine alpine-jre}
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
	TAGS=${2:-almalinux9-17 almalinux9-17-jre almalinux9-jvmless alpine alpine-jre}
	PFTAG=$1
	GITTAG=$3
	if [ "$GITTAG" != "" ]
	then
		PFTAG=$GITTAG-light
		CHECKOUT=$GITTAG
	fi
elif [ "$1" = "5.0" -o "$1" = "5.0-light" -o "$1" = "5.1" -o "$1" = "5.1-light" -o "$1" = "5.2" -o "$1" = "5.2-light" ]
then
	VERSION=5
	BRANCH=$1
	TAGS=${2:-almalinux9-17}
	PFTAG=$1
elif [ "$1" = "6-devel" ]
then
	VERSION=6
	# Release branch
	BRANCH=6.2
	TAGS=devel
	PFTAG=$1
elif [ "$1" = "6-preview" ]
then
	VERSION=6
	BRANCH=6.2-preview
	TAGS=${2:-almalinux9-21}
	PFTAG=$1
elif [ "$1" = "6-latest" -o "$1" = "6" ]
then
	VERSION=6
	BRANCH=6.2
	TAGS=${2:-almalinux9-21 almalinux9-21-jre almalinux9-jvmless alpine alpine-jre}
	PFTAG=$1
elif [ "$1" = "6-latest-light" -o "$1" = "6-light" ]
then
	VERSION=6
	BRANCH=6.2-light
	TAGS=${2:-almalinux9-21 almalinux9-21-jre almalinux9-jvmless alpine alpine-jre}
	PFTAG=$1
#elif [ "$1" = "6-beta" ]
#then
#	VERSION=6
#	BRANCH=6.3
#	TAGS=${2:-almalinux9-21 almalinux9-21-jre}
#	#TAGS=${2:-almalinux9-21 almalinux9-21-jre almalinux9-jvmless alpine}
#	PFTAG=$1
#	DOCKERFILE=${DOCKERFILE_DEFAULT}-tmp-$$
#	sed 's/^# HEALTHCHECK/HEALTHCHECK/' $DOCKERFILE_DEFAULT > $DOCKERFILE
#elif [ "$1" = "6-beta-light" ]
#then
#	VERSION=6
#	BRANCH=6.3-light
#	TAGS=${2:-almalinux9-21 almalinux9-21-jre}
#	#TAGS=${2:-almalinux9-21 almalinux9-21-jre almalinux9-jvmless alpine}
#	PFTAG=$1
#	DOCKERFILE=${DOCKERFILE_DEFAULT}-tmp-$$
#	sed 's/^# HEALTHCHECK/HEALTHCHECK/' $DOCKERFILE_DEFAULT > $DOCKERFILE
elif [ "$1" = "6-alpha" ]
then
	VERSION=6
	BRANCH=6.3
	TAGS=${2:-almalinux9-21 almalinux9-21-jre}
	#TAGS=${2:-almalinux9-21 almalinux9-21-jre almalinux9-jvmless alpine}
	PFTAG=$1
	DOCKERFILE=${DOCKERFILE_DEFAULT}-tmp-$$
	sed 's/^# HEALTHCHECK/HEALTHCHECK/' $DOCKERFILE_DEFAULT > $DOCKERFILE
elif [ "$1" = "6-alpha-light" ]
then
	VERSION=6
	BRANCH=6.3-light
	TAGS=${2:-almalinux9-21 almalinux9-21-jre}
	#TAGS=${2:-almalinux9-21 almalinux9-21-jre almalinux9-jvmless alpine}
	PFTAG=$1
	DOCKERFILE=${DOCKERFILE_DEFAULT}-tmp-$$
	sed 's/^# HEALTHCHECK/HEALTHCHECK/' $DOCKERFILE_DEFAULT > $DOCKERFILE
elif [ "$1" = "6-alpha-devel" ]
then
	VERSION=6
	BRANCH=6.3
	TAGS=devel
	PFTAG=$1
	DOCKERFILE=${DOCKERFILE_DEFAULT}-tmp-$$
	sed 's/^# HEALTHCHECK/HEALTHCHECK/' $DOCKERFILE_DEFAULT > $DOCKERFILE
elif [ "$1" = "6.0" -o "$1" = "6.0-light" -o "$1" = "6.1" -o "$1" = "6.1-light" ]
then
	VERSION=6
	BRANCH=$1
	TAGS=${2:-almalinux9-21}
	PFTAG=$1
#elif [ "$1" = "7-preview" ]
#then
#	VERSION=7
#	BRANCH=7.0-preview
#	TAGS=almalinux9-21-tomcat11
#	PFTAG=$1
#	DOCKERFILE=${DOCKERFILE_DEFAULT}-tmp-$$
#	sed 's/^# HEALTHCHECK/HEALTHCHECK/' $DOCKERFILE_DEFAULT > $DOCKERFILE
elif [ "$1" = "7-alpha" ]
then
	VERSION=7
	BRANCH=7.0
	TAGS=${2:-almalinux9-21-tomcat11 almalinux9-21-jre-tomcat11}
	#TAGS=${2:-almalinux9-21 almalinux9-21-jre almalinux9-jvmless alpine}
	PFTAG=$1
	DOCKERFILE=${DOCKERFILE_DEFAULT}-tmp-$$
	sed 's/^# HEALTHCHECK/HEALTHCHECK/' $DOCKERFILE_DEFAULT > $DOCKERFILE
elif [ "$1" = "7-alpha-light" ]
then
	VERSION=7
	BRANCH=7.0-light
	TAGS=${2:-almalinux9-21-tomcat11 almalinux9-21-jre-tomcat11}
	#TAGS=${2:-almalinux9-21 almalinux9-21-jre almalinux9-jvmless alpine}
	PFTAG=$1
	DOCKERFILE=${DOCKERFILE_DEFAULT}-tmp-$$
	sed 's/^# HEALTHCHECK/HEALTHCHECK/' $DOCKERFILE_DEFAULT > $DOCKERFILE
#elif [ "$1" = "7-alpha-devel" ]
#then
#	VERSION=7
#	BRANCH=7.0
#	TAGS=devel-tomcat11
#	PFTAG=$1
#	DOCKERFILE=${DOCKERFILE_DEFAULT}-tmp-$$
#	sed 's/^# HEALTHCHECK/HEALTHCHECK/' $DOCKERFILE_DEFAULT > $DOCKERFILE
else
	rm -f $LOCK
	exit_with 3 "Unknown variant: $1"
fi

REGISTRY=registry.simplicite.io
SRVIMG=$REGISTRY/server
PFIMG=$REGISTRY/platform
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

for TAG in $TAGS
do
	EXT=""
	[ $TAG != "devel" ] && EXT="-$TAG"
	[ $SERVER != "tomcat" ] && EXT="$EXT-$SERVER"
	echo "========================================================"
	echo "Building $PFIMG:$PFTAG$EXT image from $SRVIMG:$TAG..."
	echo "========================================================"
	DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
	DESTPATH="tomcat"
	[ $TAG = "jetty" ] && DESTPATH="jetty/default"
	[ $DEL = 1 ] && docker rmi $PFIMG:$PFTAG$EXT > /dev/null 2>&1
	docker build $NOCACHE --network host -f $DOCKERFILE --build-arg date=$DATE --build-arg tag=$TAG --build-arg version=$VERSION --build-arg patchlevel=$PATCHLEVEL --build-arg revision=$REVISION --build-arg commitid=$COMMITID --build-arg template=$TEMPLATE --build-arg destpath=$DESTPATH -t $PFIMG:$PFTAG$EXT .
	echo "Done"
done

rm -f $DOCKERFILE_DEFAULT-tmp-*

echo "Removing $TEMPLATE..."
rm -fr $TEMPLATE
echo "Done"
echo ""

exit_with
