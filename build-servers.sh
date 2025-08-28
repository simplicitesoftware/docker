#!/bin/bash

[ "$1" = "--help" ] && exit_with 1 "\nUsage: \e[1m$(basename $0)\e[0m\n" 

REGISTRY=registry.simplicite.io

# Tomcat
for BRANCH in master tomcat11
do
	./build-server.sh all tomcat $BRANCH
	RES=$?
	[ $RES -ne 0 ] && exit $RES
done

./push-to-registries.sh server

exit 0
