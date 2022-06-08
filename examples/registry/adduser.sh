#!/bin/bash

if [ "$1" = "" -o "$1" = "--help" ]
then
	echo -e "\nUsage: `basename $0` <user>\n" >&2
	exit -1
fi

DIR=${REGISTRY_DIR:-/mnt/registry}

USER=$1
PWD=$2
[ "$PWD" = "" ] && PWD=`date | md5sum | awk '{print $1}'`

echo "User: $USER"
echo "Password: $PWD"
[ ! -d $DIR/auth ] && mkdir $DIR/auth
[ ! -f $DIR/auth/users.pwd ] && touch $DIR/auth/users.pwd
htpasswd -B -b $DIR/auth/users.pwd $USER $PWD
exit $?
