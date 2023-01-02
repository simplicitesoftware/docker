#!/bin/bash

LOCK=/tmp/$(basename $0 .sh).lck

exit_with () {
	[ "$2" != "" ] && echo -e $2 >&2
	rm -f $LOCK
	exit ${1:-0}
}

[ "$1" = "--help" ] && exit_with 1 "\nUsage: \e[1m$(basename $0)\e[0m\n"

trap "rm -f $LOCK" TERM INT QUIT HUP
[ -f $LOCK ] && exit_with 2 "A build process is in process since $(cat $LOCK)"
date > $LOCK

echo ""
echo "--------------------------------------------------------"

SRV=jetty
SERVER=simplicite/server
TAG=jetty

echo "Updating $SRV.git"
cd $SRV.git
git config remote.origin.fetch 'refs/heads/*:refs/heads/*' || exit_with 3 "Unable to configure fetch origin in $SRV.git"
git fetch --verbose --all --force || exit_with 4 "Unable to fetch in $SRV.git"
cd ..
echo "Done"

echo "Checkouting $SRV"
rm -fr $SRV
mkdir $SRV
git --work-tree=$SRV --git-dir=$SRV.git checkout -f master || exit_with 5 "Unable to checkout master branch from $SRV.git"
rm -f $SRV/.project $SRV/.git* $SRV/README.md $SRV/*.bat $SRV/bin/*.bat $SRV/bin/*.exe $SRV/bin/*.dll
echo "Done"

FROM=$(grep '^FROM' Dockerfile-$TAG | awk '{ print $2 }')
echo "Pulling image: $FROM"
docker pull $FROM
echo "Done"

echo "========================================================"
echo "Building $SERVER:$TAG image..."
echo "========================================================"
DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
docker rmi $SERVER:$TAG
docker build --network host -f Dockerfile-$TAG -t $SERVER:$TAG --build-arg date="$DATE" .
echo "Done"

rm -fr $SRV

echo ""
echo "-- $SERVER:$TAG$SRVEXT$JVMEXT ------------------"
echo ""
echo "docker run -it --rm --memory=128m -p 127.0.0.1:8443:8080 --name=simplicite $SERVER:$TAG"
echo ""

exit_with
