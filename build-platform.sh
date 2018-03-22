#!/bin/bash

TAGS="centos alpine"
[ "$1" != "" ] && TAGS=$1
SRVS="tomcat tomee"
[ "$2" != "" ] && SRVS=$2

BRANCH=release
TEMPLATE=template-4.0-$BRANCH
SERVER=simplicite/server
PLATFORM=simplicite/platform
DB=docker
IP=`ifconfig eth0 | grep 'inet ' | awk '{print $2}'`

cd $TEMPLATE
git pull

# ZZZ temporary ZZZ
CVDB=template40
if [ ! -f app/WEB-INF/db/simplicite-mysql.dmp ]
then
	echo "Preparing MySQL dump..."
	./convert-mysql.sh --drop --dump $CVDB
	mv -f simplicite-mysql.dmp ../app/WEB-INF/db
	echo "Done"
fi
if [ ! -f app/WEB-INF/db/simplicite-postgresql.dmp ]
then
	echo "Preparing PostgreSQL dump..."
	./convert-postgresql.sh --drop --dump $CVDB
	mv -f simplicite-postgresql.dmp ../app/WEB-INF/db
	echo "Done"
fi

for SRV in $SRVS
do
	TAGEXT=""
	[ $SRV != "tomcat" ] && TAGEXT="-$SRV"
	for TAG in $TAGS
	do
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
LABEL org.label-schema.build-date="$DATE" \
      org.label-schema.name="simplicite" \
      org.label-schema.description="Simplicite platform" \
      org.label-schema.vendor="Simplicite Software" \
      org.label-schema.version="$VERSION.$PATHCHLEVEL (revision $REVISION)" \
      org.label-schema.url="https://www.simplicite.io"
COPY $TEMPLATE/app /usr/local/tomcat/webapps/ROOT
EOF
		sudo docker build -f Dockerfile -t $PLATFORM:$TAG$TAGEXT .
		rm -f Dockerfile
		echo "Done"
	done
done

echo ""
for SRV in $SRVS
do
	TAGEXT=""
	[ $SRV != "tomcat" ] && TAGEXT="-$SRV"
	for TAG in $TAGS
	do
		echo "-- $PLATFORM:$TAG$TAGEXT ------------------"
		echo "sudo docker run -it --rm -p 9090:8080 -p 9443:8443 $PLATFORM:$TAG$TAGEXT"
		echo "sudo docker run -it --rm -p 9090:8080 -p 9443:8443 -e DB_SETUP=true -e DB_VENDOR=mysql -e DB_HOST=$IP -e DB_PORT=3306 -e DB_USER=$DB -e DB_PASSWORD=$DB -e DB_NAME=$DB $PLATFORM:$TAG$TAGEXT"
		echo "sudo docker run -it --rm -p 9090:8080 -p 9443:8443 -e DB_SETUP=true -e DB_VENDOR=postgresql -e DB_HOST=$IP -e DB_PORT=5432 -e DB_USER=$DB -e DB_PASSWORD=$DB -e DB_NAME=$DB $PLATFORM:$TAG$TAGEXT"
		echo "sudo docker push $PLATFORM:$TAG$TAGEXT"
		if [ $TAG = "centos" -a $SRV = "tomcat" ]
		then
			echo "sudo docker tag $PLATFORM:$TAG$TAGEXT $PLATFORM:latest"
			echo "sudo docker push $PLATFORM:latest"
		fi
		# ZZZ Temporary ZZZZZZZZZZZZZZZZZZZZ
		if [ $TAG = "centos" ]
		then
			DT=`date +%Y%m%d`
			echo "sudo docker tag $PLATFORM:$TAG$TAGEXT $PLATFORM:$TAG$TAGEXT-$DT"
			echo "sudo docker push $PLATFORM:$TAG$TAGEXT-$DT"
		fi
		# ZZZ Temporary ZZZZZZZZZZZZZZZZZZZZ
		echo ""
	done
done

exit 0
