#!/bin/bash

if [ "$1" = "--help" ]
then
	echo "Usage: `basename $0` [<tag(s)> [<server(s)>]]" >&2
	exit 0
fi

TAGS="centos alpine"
[ "$1" != "" ] && TAGS=$1
#SRVS="tomcat tomcat9 tomee"
SRVS="tomcat tomcat9"
[ "$2" != "" ] && SRVS=$2

SERVER=simplicite/server

echo "Updating base images..."
sudo docker pull docker.io/centos
sudo docker pull docker.io/openjdk:alpine
echo "Done"

for SRV in $SRVS
do
	echo "Copying $SRV..."
	rm -fr ./tomcat
	cp -r -L ../$SRV tomcat
	echo "Done"

	TAGEXT=""
	[ $SRV != "tomcat" ] && TAGEXT="-$SRV"
	for TAG in $TAGS
	do
		echo "========================================================"
		echo "Building $SERVER:$TAG$TAGEXT image..."
		echo "========================================================"
		sudo docker build -f Dockerfile-$TAG -t $SERVER:$TAG$TAGEXT .
		echo "Done"
	done
done
rm -fr ./tomcat

echo ""
for SRV in $SRVS
do
	TAGEXT=""
	[ $SRV != "tomcat" ] && TAGEXT="-$SRV"
	for TAG in $TAGS
	do
		echo "-- $SERVER:$TAG$TAGEXT ------------------"
		echo "sudo docker run -it --rm -p 9090:8080 -p 9443:8443 $SERVER:$TAG$TAGEXT"
		echo "sudo docker push $SERVER:$TAG$TAGEXT"
		if [ $TAG = "centos" -a $SRV = "tomcat" ]
		then
			echo "sudo docker tag $SERVER:$TAG$TAGEXT $SERVER:latest"
			echo "sudo docker push $SERVER:latest"
			echo "sudo docker rmi $SERVER:latest"
		fi
		echo ""
	done
done

exit 0
