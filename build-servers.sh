#!/bin/bash

# Tomcat
for BRANCH in master tomcat11
do
	./build-server.sh all tomcat $BRANCH
	RES=$?
	[ $RES -ne 0 ] && exit $RES
done

./push-to-registries.sh server

exit 0
