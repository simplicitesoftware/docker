#!/bin/bash

TAGS="centos alpine"
[ "$1" != "" ] && TAGS=$1
SRVS="tomcat tomee"
[ "$2" != "" ] && SRVS=$2

SERVER=simplicite/server
PLATFORM=simplicite/platform
DB=docker
IP=`ifconfig eth0 | grep 'inet ' | awk '{print $2}'`

echo "Updating and copying template..."
cd template-4.0-release
git pull
cd ..
rm -fr template
rsync -a --exclude='.git' --exclude='.gitignore' template-4.0-release/ template
rm -f template/app/WEB-INF/db/*.dmp
sed -i "/INSERT INTO M_SYSTEM VALUES.*'PUBLIC_PAGES'/s/'yes'/'no'/" template/app/WEB-INF/db/simplicite.script
echo "Done"

cd template/tools

echo "Preparing MySQL dump..."
./convert-mysql.sh --dump > /dev/null
mv -f simplicite-mysql.dmp ../app/WEB-INF/db
echo "Done"

echo "Preparing PostgreSQL dump..."
./convert-postgresql.sh --dump > /dev/null
mv -f simplicite-postgresql.dmp ../app/WEB-INF/db
echo "Done"

cd ../..

for SRV in $SRVS
do
	TAGEXT=""
	[ $SRV != "tomcat" ] && TAGEXT="-$SRV"
	for TAG in $TAGS
	do
		echo "========================================================"
		echo "Building $PLATFORM:$TAG$TAGEXT image..."
		echo "========================================================"
		cat > Dockerfile << EOF
FROM $SERVER:$TAG$TAGEXT
MAINTAINER Simplicite.io <contact@simplicite.io>
COPY template/app /usr/local/tomcat/webapps/ROOT
EOF
		sudo docker build -f Dockerfile -t $PLATFORM:$TAG$TAGEXT .
		rm -f Dockerfile
		echo "Done"
	done
done
rm -fr template

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
