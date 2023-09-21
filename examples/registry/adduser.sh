#!/bin/bash

if [ "$1" = "" -o "$1" = "--help" ]
then
	echo -e "\nUsage: \e[1m$(basename $0)\e[0m <user>\n" >&2
	exit -1
fi

DIR=${REGISTRY_DIR:-/mnt/data}/auth

USER=$1
PWD=$2
[ "$PWD" = "" ] && PWD=$(date | md5sum | awk '{print $1}')

echo "User: $USER"
echo "Password: $PWD"
[ ! -d $DIR ] && mkdir $DIR
[ ! -f $DIR/users.pwd ] && touch $DIR/users.pwd
cp -f $DIR/users.pwd $DIR/users.bak
htpasswd -B -b $DIR/users.pwd $USER $PWD
exit $?
