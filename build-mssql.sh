#!/bin/bash

if [ "$1" = "--help" ]
then
	echo "Usage: `basename $0`" >&2
	exit 1
fi

LOCK=/tmp/`basename $0 .sh`.lck
if [ -f $LOCK ]
then
	echo "A build process is in process since `cat $LOCK`" >&2
	exit 2
fi
date > $LOCK

cd mssql

IMG=simplicite/mssql:latest
echo "========================================================"
echo "Building $IMG image..."
echo "========================================================"
FROM=`grep FROM Dockerfile | awk '{ print $2 }'`
sudo docker pull $FROM
sudo docker build --network host -t $IMG .
echo "Done"

echo "-- $IMG ------------------"
echo "sudo docker run -it --rm -e SA_PASSWORD="A_Str0ng_Passw0rd_for_SA_" -p 1433:1433 $IMG"
echo "sudo docker push $IMG"
echo ""

cd ..

rm -f $LOCK
exit 0
