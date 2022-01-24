#!/bin/bash

LOCK=/tmp/`basename $0 .sh`.lck
trap "rm -f $LOCK" TERM INT QUIT HUP
if [ -f $LOCK ]
then
	echo "A build process is in process since `cat $LOCK`" >&2
	exit 2
fi
date > $LOCK

echo ""
echo "--------------------------------------------------------"

SRV=jetty
SERVER=server
TAG=jetty

echo "Updating $SRV.git"
cd $SRV.git
git config remote.origin.fetch 'refs/heads/*:refs/heads/*'
git fetch --verbose --all --force
cd ..
echo "Done"

echo "Checkouting $SRV"
rm -fr $SRV
mkdir $SRV
git --work-tree=$SRV --git-dir=$SRV.git checkout -f master
rm -f $SRV/.project $SRV/.git* $SRV/README.md $SRV/*.bat $SRV/bin/*.bat $SRV/bin/*.exe $SRV/bin/*.dll
sed -i 's/# jetty.http.port=8080/jetty.http.port=8443/' $SRV/default/start.d/http.ini
#sed -i 's/# jetty.httpConfig.secureScheme=/jetty.httpConfig.secureScheme=/;s/# jetty.httpConfig.securePort=/jetty.httpConfig.securePort=/' $SRV/default/start.d/server.ini
echo "Done"

FROM=`grep '^FROM' Dockerfile-$TAG | awk '{ print $2 }'`
echo "Pulling image: $FROM"
docker pull $FROM
echo "Done"

echo "========================================================"
echo "Building $SERVER:$TAG image..."
echo "========================================================"
DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
docker rmi $SERVER:$TAG
docker build --network host -f Dockerfile-$TAG -t $SERVER:$TAG --build-arg date="$DATE" .
echo "Done"

rm -fr $SRV

echo ""
echo "-- $SERVER:$TAG$SRVEXT$JVMEXT ------------------"
echo ""
echo "docker run -it --rm --memory=128m -p 127.0.0.1:8080:8080 -p 127.0.0.1:8443:8443 --name=simplicite $SERVER:$TAG"
echo ""

rm -f $LOCK
exit 0
