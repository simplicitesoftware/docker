#!/bin/bash

if [ "$1" = "" ]
then
	echo "Usage: `basename $0` <all|alpha|beta|latest>" >&2 
	exit -1
fi

if [ "$1" = "alpha" -o "$1" = "all" ]
then
	./build-platform.sh 5-alpha
	./build-platform.sh 5-alpha-light
	./build-platform.sh 5-alpha-test
fi

if [ "$1" = "beta" -o "$1" = "all" ]
then
	./build-platform.sh 5-beta
	./build-platform.sh 5-beta-light
fi

if [ "$1" = "latest" -o "$1" = "all" ]
then
	./build-platform.sh 5-latest
	docker tag simplicite/platform:5-latest simplicite/platform:5
	docker tag simplicite/platform:5-latest simplicite/platform:latest

	./build-platform.sh 5-latest-light
	docker tag simplicite/platform:5-latest-light simplicite/platform:5-light
	docker tag simplicite/platform:5-latest-light simplicite/platform:latest-light
fi

exit 0
