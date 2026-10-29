#!/bin/bash

if [ "$1" = "--help" ]
then
	echo -e  "\nUsage: \e[1m$(basename $0)\e[0m [all|devel]]\n" >&2
	exit 1
fi

TOMCAT_BRANCHES="master tomcat11"

for TOMCAT_BRANCHE in $TOMCAT_BRANCHES
do
	./build-server.sh ${1:-all} tomcat $TOMCAT_BRANCHE
	RES=$?
	[ $RES -ne 0 ] && exit $RES
done

./push-to-registries.sh server

exit 0
