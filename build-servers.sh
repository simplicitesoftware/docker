#!/bin/bash

if [ "$1" = "--help" ]
then
	echo -e  "\nUsage: \e[1m$(basename $0)\e[0m [all|devel]\n" >&2
	exit 1
fi

BRANCHES="master tomcat11"

for BRANCH in $BRANCHES
do
	./build-server.sh ${1:-all} tomcat $BRANCH
	RES=$?
	[ $RES -ne 0 ] && exit $RES
done

if [ ${1:-all} = "devel" ]
then
	./push-to-registries.sh server $(docker images registry.simplicite.io/server --format '{{.Tag}}' | grep 'devel' | xargs)
else
	./push-to-registries.sh server
fi

exit 0
