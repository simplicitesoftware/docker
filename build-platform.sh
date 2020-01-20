#!/bin/bash

if [ "$1" = "" -o "$1" = "--help" ]
then
	echo "Usage: `basename $0` alpha[-light]|beta[-light]|latest" >&2
	exit 1
fi

LOCK=/tmp/`basename $0 .sh`.lck
if [ -f $LOCK ]
then
	echo "A build process is in process since `cat $LOCK`" >&2
	exit 2
fi
date > $LOCK

if [ "$1" = "3.1" ]
then
	VERSION=3.1
	BRANCH=master
	TAGS=centos
	SRVS=tomcat
	PFTAG=3.1
elif [ "$1" = "3.2" ]
then
	VERSION=3.2
	BRANCH=master
	TAGS=centos
	SRVS=tomcat
	PFTAG=3.2
elif [ "$1" = "test" ]
then
	VERSION=4.0
	BRANCH=master
	TAGS=centos8
	SRVS=tomcat
	PFTAG=test
elif [ "$1" = "master" -o "$1" = "alpha" ]
then
	VERSION=4.0
	BRANCH=master
	TAGS=centos
	SRVS=tomcat
	PFTAG=alpha
elif [ "$1" = "master-light" -o "$1" = "alpha-light" ]
then
	VERSION=4.0
	BRANCH=master-light
	TAGS=centos
	SRVS=tomcat
	PFTAG=alpha-light
elif [ "$1" = "prerelease" -o "$1" = "beta" ]
then
	VERSION=4.0
	BRANCH=prerelease
	TAGS=centos
	SRVS=tomcat
	PFTAG=beta
elif [ "$1" = "prerelease-light" -o "$1" = "beta-light" ]
then
	VERSION=4.0
	BRANCH=prerelease-light
	TAGS=centos
	SRVS=tomcat
	PFTAG=beta-light
elif [ "$1" = "release" -o "$1" = "latest" ]
then
	VERSION=4.0
	BRANCH=release
	TAGS="centos alpine"
	SRVS=tomcat
	PFTAG=latest
elif [ "$1" = "release-light" -o "$1" = "latest-light" ]
then
	VERSION=4.0
	BRANCH=release-light
	TAGS="centos alpine"
	SRVS=tomcat
	PFTAG=latest-light
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
echo "Done"

cd $TEMPLATE

for SRV in $SRVS
do
	for TAG in $TAGS
	do
		EXT=""
		[ $TAG != "centos" ] && EXT="-$TAG"
		[ $SRV != "tomcat" ] && EXT="$EXT-$SRV"
		echo "========================================================"
		echo "Building $PLATFORM:$PFTAG$EXT image..."
		echo "========================================================"
		DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
		PROPS=app/WEB-INF/classes/com/simplicite/globals.properties
		VERSION=`grep platform.version $PROPS | awk -F= '{print $2}'`
		PATCHLEVEL=`grep platform.patchlevel $PROPS | awk -F= '{print $2}'`
		REVISION=`grep platform.revision $PROPS | awk -F= '{print $2}'`
		cat > Dockerfile.$$ << EOF
FROM $SERVER:$TAG
LABEL org.label-schema.name="simplicite" \\
      org.label-schema.vendor="Simplicite Software" \\
      org.label-schema.url="https://www.simplicite.io" \\
      org.label-schema.description="Simplicite platform $BRANCH / $TAG / $SRV" \\
      org.label-schema.version="$VERSION.$PATCHLEVEL" \\
      org.label-schema.vcs-ref="$REVISION" \\
      org.label-schema.license="https://www.simplicite.io/resources/license.md" \\
      org.label-schema.build-date="$DATE"
COPY app /usr/local/tomcat/webapps/ROOT
EOF
		sudo docker build --network host -f Dockerfile.$$ -t $PLATFORM:$PFTAG$EXT .
		rm -f Dockerfile.$$
		echo "Done"
	done
done

cd ..
rm -fr $TEMPLATE

echo ""
DB=docker
IP=`ifconfig eth0 | grep 'inet ' | awk '{print $2}'`
for SRV in $SRVS
do
	for TAG in $TAGS
	do
		EXT=""
		[ $TAG != "centos" ] && EXT="-$TAG"
		[ $SRV != "tomcat" ] && EXT="$EXT-$SRV"
		echo "-- $PLATFORM:$PFTAG$EXT ------------------"
		echo "sudo docker run -it --rm -p 9090:8080 -p 9443:8443 $PLATFORM:$PFTAG$EXT"
		echo "sudo docker run -it --rm -p 9090:8080 -p 9443:8443 -e DB_SETUP=true -e DB_VENDOR=mysql -e DB_HOST=$IP -e DB_PORT=3306 -e DB_USER=$DB -e DB_PASSWORD=$DB -e DB_NAME=$DB $PLATFORM:$PFTAG$EXT"
		echo "sudo docker run -it --rm -p 9090:8080 -p 9443:8443 -e DB_SETUP=true -e DB_VENDOR=postgresql -e DB_HOST=$IP -e DB_PORT=5432 -e DB_USER=$DB -e DB_PASSWORD=$DB -e DB_NAME=$DB $PLATFORM:$PFTAG$EXT"
		echo "sudo docker push $PLATFORM:$PFTAG$EXT"
		if [ $PFTAG = "latest" -a $TAG = "centos" -a $SRV = "tomcat" ]
		then
			echo "sudo docker tag $PLATFORM:$PFTAG $PLATFORM:$VERSION"
			echo "sudo docker push $PLATFORM:$VERSION"
			echo "sudo docker rmi $PLATFORM:$VERSION"
			echo "sudo docker tag $PLATFORM:$PFTAG $PLATFORM:$VERSION.$PATCHLEVEL"
			echo "sudo docker push $PLATFORM:$VERSION.$PATCHLEVEL"
			echo "sudo docker rmi $PLATFORM:$VERSION.$PATCHLEVEL"
		fi
		if [ $PFTAG = "latest-light" -a $TAG = "centos" -a $SRV = "tomcat" ]
		then
			echo "sudo docker tag $PLATFORM:$PFTAG $PLATFORM:$VERSION-light"
			echo "sudo docker push $PLATFORM:$VERSION-light"
			echo "sudo docker rmi $PLATFORM:$VERSION-light"
			echo "sudo docker tag $PLATFORM:$PFTAG $PLATFORM:$VERSION.$PATCHLEVEL-light"
			echo "sudo docker push $PLATFORM:$VERSION.$PATCHLEVEL-light"
			echo "sudo docker rmi $PLATFORM:$VERSION.$PATCHLEVEL-light"
		fi
		echo ""
	done
done

rm -f $LOCK
exit 0
