#!/bin/bash

if [ "$1" = "--help" ]
then
	echo "Usage: `basename $0` [master|<tag(s)> [<server(s)>]]" >&2
	exit 0
fi

if [ "$1" = "master" -o "$1" = "nightly" ]
then
	BRANCH=master
	TAGS=centos
	SRVS=tomcat9
else
	BRANCH=release
	TAGS="centos alpine"
	[ "$1" != "" ] && TAGS=$1
	SRVS="tomcat tomee"
	[ "$2" != "" ] && SRVS=$2
fi

TEMPLATE=template-4.0-$BRANCH
SERVER=simplicite/server
PLATFORM=simplicite/platform

cd $TEMPLATE
git pull

for SRV in $SRVS
do
	TAGEXT=""
	[ $SRV != "tomcat" ] && TAGEXT="-$SRV"
	for TAG in $TAGS
	do
		PFTAG=$TAG$TAGEXT
		[ $BRANCH = "master" ] && PFTAG="nightly"
		echo "========================================================"
		echo "Building $PLATFORM:$TAG$TAGEXT image..."
		echo "========================================================"
		DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
		PROPS=app/WEB-INF/classes/com/simplicite/globals.properties
		VERSION=`grep platform.version $PROPS | awk -F= '{print $2}'`
		PATCHLEVEL=`grep platform.patchlevel $PROPS | awk -F= '{print $2}'`
		REVISION=`grep platform.revision $PROPS | awk -F= '{print $2}'`
		cat > Dockerfile << EOF
FROM $SERVER:$TAG$TAGEXT
LABEL org.label-schema.name="simplicite" \\
      org.label-schema.vendor="Simplicite Software" \\
      org.label-schema.url="https://www.simplicite.io" \\
      org.label-schema.description="Simplicite platform $BRANCH / $TAG / $SRV" \\
      org.label-schema.version="$VERSION.$PATCHLEVEL (revision $REVISION)" \\
      org.label-schema.license="https://www.simplicite.io/resources/license.md" \\
      org.label-schema.build-date="$DATE"
COPY app /usr/local/tomcat/webapps/ROOT
EOF
		sudo docker build -f Dockerfile -t $PLATFORM:$PFTAG .
		rm -f Dockerfile
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
		[ $BRANCH = "master" ] && PFTAG="nightly"
		echo "-- $PLATFORM:$PFTAG ------------------"
		echo "sudo docker run -it --rm -p 9090:8080 -p 9443:8443 $PLATFORM:$PFTAG"
		echo "sudo docker run -it --rm -p 9090:8080 -p 9443:8443 -e DB_SETUP=true -e DB_VENDOR=mysql -e DB_HOST=$IP -e DB_PORT=3306 -e DB_USER=$DB -e DB_PASSWORD=$DB -e DB_NAME=$DB $PLATFORM:$PFTAG"
		echo "sudo docker run -it --rm -p 9090:8080 -p 9443:8443 -e DB_SETUP=true -e DB_VENDOR=postgresql -e DB_HOST=$IP -e DB_PORT=5432 -e DB_USER=$DB -e DB_PASSWORD=$DB -e DB_NAME=$DB $PLATFORM:$PFTAG"
		echo "sudo docker push $PLATFORM:$PFTAG"
		if [ $BRANCH = "release" -a $TAG = "centos" -a $SRV = "tomcat" ]
		then
			echo "sudo docker tag $PLATFORM:$PFTAG $PLATFORM:latest"
			echo "sudo docker push $PLATFORM:latest"
			echo "sudo docker rmi $PLATFORM:latest"
			# ZZZ Temporary ZZZZZZZZZZZZZZZZZZZZ
			DT=`date +%Y%m%d`
			echo "sudo docker tag $PLATFORM:$PFTAG $PLATFORM:$PFTAG-$DT"
			echo "sudo docker push $PLATFORM:$PFTAG-$DT"
			echo "sudo docker rmi $PLATFORM:$PFTAG-$DT"
			# ZZZ Temporary ZZZZZZZZZZZZZZZZZZZZ
		fi
		echo ""
	done
done

exit 0
