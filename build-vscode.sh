#!/bin/bash

LOCK=/tmp/`basename $0 .sh`.lck

exit_with () {
	[ "$2" != "" ] && echo -e $2 >&2
	rm -f $LOCK
	exit ${1:-0}
}

[ "$1" = "--help" ] && exit_with 1 "Usage: `basename $0`"

trap "rm -f $LOCK" TERM INT QUIT HUP
[ -f $LOCK ] && exit_with 2 "A build process is in process since `cat $LOCK`"
date > $LOCK

cd vscode

IMG=simplicite/vscode:latest
echo "========================================================"
echo "Building $IMG image..."
echo "========================================================"
DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
docker build --network host -t $IMG --build-arg BUILD_DATE=$DATE . || exit_with 3 "Unable to build image $IMG"
echo "Done"
echo ""
echo "docker run -it --rm -p 127.0.0.1:3030:3030 --name=vscode $IMG"
echo ""

cd ..

exit_with
