#!/bin/bash

if [ "$1" = "--help" ]
then
	echo "Usage: `basename $0` [master|prerelease|<tag(s)> [<server(s)>]]" >&2
	exit 1
fi

if [ "$1" = "master" -o "$1" = "alpha" ]
then
	BRANCH=master
	TAGS=centos
	SRVS=tomcat
elif [ "$1" = "prerelease" -o "$1" = "beta" ]
then
	BRANCH=prerelease
	TAGS=centos
	SRVS=tomcat
else
	BRANCH=release
	TAGS="centos alpine"
	[ "$1" != "" ] && TAGS=$1
	#SRVS="tomcat tomee"
	SRVS=tomcat
	[ "$2" != "" ] && SRVS=$2
fi

TEMPLATE=template-4.0
SERVER=simplicite/server
PLATFORM=simplicite/platform

if [ ! -d $TEMPLATE.git ]
then
	echo "Git repository for template $TEMPLATE not cloned: git clone --bare <path to $TEMPLATE>.git" >&2
	exit 2
fi

cd $TEMPLATE.git
git config remote.origin.fetch 'refs/heads/*:refs/heads/*'
git fetch --verbose --all --force
cd ..
rm -fr $TEMPLATE
mkdir $TEMPLATE
git --work-tree=$TEMPLATE --git-dir=$TEMPLATE.git checkout -f $BRANCH
cd $TEMPLATE

for SRV in $SRVS
do
	TAGEXT=""
	[ $SRV != "tomcat" ] && TAGEXT="-$SRV"
	for TAG in $TAGS
	do
		PFTAG=$TAG$TAGEXT
		[ $BRANCH = "master" ] && PFTAG="alpha"
		[ $BRANCH = "prerelease" ] && PFTAG="beta"
		echo "========================================================"
		echo "Building $PLATFORM:$TAG$TAGEXT image..."
		echo "========================================================"
		DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
		PROPS=app/WEB-INF/classes/com/simplicite/globals.properties
		VERSION=`grep platform.version $PROPS | awk -F= '{print $2}'`
		PATCHLEVEL=`grep platform.patchlevel $PROPS | awk -F= '{print $2}'`
		REVISION=`grep platform.revision $PROPS | awk -F= '{print $2}'`
		cat > Dockerfile.$$ << EOF
FROM $SERVER:$TAG$TAGEXT
LABEL org.label-schema.name="simplicite" \\
      org.label-schema.vendor="Simplicite Software" \\
      org.label-schema.url="https://www.simplicite.io" \\
      org.label-schema.description="Simplicite platform $BRANCH / $TAG / $SRV" \\
      org.label-schema.version="$VERSION.$PATCHLEVEL" \\
      org.label-schema.vcs-ref="$REVISION" \\
      org.label-schema.license="https://www.simplicite.io/resources/license.md" \\
      org.label-schema.build-date="$DATE"
COPY app /usr/local/tomcat/webapps/ROOT
#VOLUME /usr/local/tomcat/webapps/ROOT/WEB-INF/db /usr/local/tomcat/webapps/ROOT/WEB-INF/dbdoc
EOF
		sudo docker build -f Dockerfile.$$ -t $PLATFORM:$PFTAG .
		rm -f Dockerfile.$$
		echo "Done"
	done
done

cd ..

echo ""
DB=docker
IP=`ifconfig eth0 | grep 'inet ' | awk '{print $2}'`
for SRV in $SRVS
do
	TAGEXT=""
	[ $SRV != "tomcat" ] && TAGEXT="-$SRV"
	for TAG in $TAGS
	do
		PFTAG=$TAG$TAGEXT
		[ $BRANCH = "master" ] && PFTAG="alpha"
		[ $BRANCH = "prerelease" ] && PFTAG="beta"
		echo "-- $PLATFORM:$PFTAG ------------------"
		echo "sudo docker run -it --rm -p 9090:8080 -p 9443:8443 $PLATFORM:$PFTAG"
		echo "sudo docker run -it --rm -p 9090:8080 -p 9443:8443 -e DB_SETUP=true -e DB_VENDOR=mysql -e DB_HOST=$IP -e DB_PORT=3306 -e DB_USER=$DB -e DB_PASSWORD=$DB -e DB_NAME=$DB $PLATFORM:$PFTAG"
		echo "sudo docker run -it --rm -p 9090:8080 -p 9443:8443 -e DB_SETUP=true -e DB_VENDOR=postgresql -e DB_HOST=$IP -e DB_PORT=5432 -e DB_USER=$DB -e DB_PASSWORD=$DB -e DB_NAME=$DB $PLATFORM:$PFTAG"
		echo "sudo docker push $PLATFORM:$PFTAG"
		if [ $BRANCH = "release" -a $SRV = "tomcat" ]
		then
			echo "sudo docker tag $PLATFORM:$PFTAG $PLATFORM:$VERSION.$PATCHLEVEL-$TAG"
			echo "sudo docker push $PLATFORM:$VERSION.$PATCHLEVEL-$TAG"
			echo "sudo docker rmi $PLATFORM:$VERSION.$PATCHLEVEL-$TAG"
			if [ $TAG = "centos" ]
			then
				echo "sudo docker tag $PLATFORM:$PFTAG $PLATFORM:latest"
				echo "sudo docker push $PLATFORM:latest"
				echo "sudo docker rmi $PLATFORM:latest"
			fi
		fi
		echo ""
	done
done

exit 0
