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

TAGS=
[ ${1:-all} = "devel" ] && TAGS=$( docker images registry.simplicite.io/server --format '{{.Tag}}' | grep 'devel')
./push-to-registries.sh server $TAGS

exit 0
