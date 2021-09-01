#!/bin/bash

if [ "$1" = "" -o "$1" = "--help" ]
then
	echo "Usage: `basename $0` <all|alpha|devel|beta|latest>" >&2 
	exit -1
fi

if [ "$1" = "alpha" -o "$1" = "all" ]
then
	./build-platform.sh --delete 5-alpha
	./build-platform.sh --delete 5-alpha-light
	./build-platform.sh --delete 5-alpha-test

	./push-to-registries.sh platform 5-alpha-test-alpine 5-alpha-test-centos8 5-alpha-light 5-alpha
fi

if [ "$1" = "devel" ]
then
	./build-platform.sh --delete 5-devel
fi

if [ "$1" = "beta" -o "$1" = "all" ]
then
	./build-platform.sh --delete 5-beta
	./build-platform.sh --delete 5-beta-light

	./push-to-registries.sh platform 5-beta-light 5-beta
fi

if [ "$1" = "latest" -o "$1" = "all" ]
then
	./build-platform.sh --delete 5-latest
	docker rmi simplicite/platform:5 simplicite/platform:latest
	docker tag simplicite/platform:5-latest simplicite/platform:5
	docker tag simplicite/platform:5-latest simplicite/platform:latest

	./push-to-registries.sh platform 5-latest-adoptopenjdk-openjdk11 5-latest-adoptopenjdk-openjdk16 5-latest-openjdk-11-jre 5-latest-openjdk-11 5-latest-jre 5-latest 5 latest 

	./build-platform.sh --delete 5-latest-light
	docker rmi simplicite/platform:5-light simplicite/platform:latest-light
	docker tag simplicite/platform:5-latest-light simplicite/platform:5-light
	docker tag simplicite/platform:5-latest-light simplicite/platform:latest-light

	./push-to-registries.sh platform 5-latest-light-adoptopenjdk-openjdk11 5-latest-light-adoptopenjdk-openjdk16 5-latest-light-openjdk-11-jre 5-latest-light-openjdk-11 5-latest-light-jre 5-latest-light 5-light latest-light
fi

# Legacy versions

if [ "$1" = "5.0" ]
then
	./build-platform.sh --delete 5.0
	./build-platform.sh --delete 5.0-light

	./push-to-registries.sh platform 5.0 5.0-light
fi

exit 0
