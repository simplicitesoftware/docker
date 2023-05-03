#!/bin/bash

exit_with () {
	[ "$2" != "" ] && echo -e $2 >&2
	exit ${1:-0}
}

PUSH=1
if [ "$1" = "--no-push" ]
then
	PUSH=0
	shift
fi

[ "$1" = "--help" ] && exit_with 1 "\nUsage: \e[1m$(basename $0)\e[0m\n" 

./build-platform.sh --delete 4.0 || exit_with $? "Unable to build platform version 4.0-latest"

docker rmi simplicite/platform:4.0-latest
docker tag simplicite/platform:4.0-temurin-17 simplicite/platform:4.0-latest

docker rmi simplicite/platform:4.0
docker tag simplicite/platform:4.0-latest simplicite/platform:4.0

if [ $PUSH -eq 1 ]
then
	#./push-to-registries.sh --public platform 4.0-latest 4.0
	./push-to-registries.sh --delete platform \
	./push-to-registries.sh platform \
		4.0-temurin-11 \
		4.0-temurin-17 \
		4.0-openjdk-11 \
		4.0-latest \
		4.0
fi

./build-platform.sh --delete 4.0-light || exit_with $? "Unable to build platform version 4.0-latest-light"

docker rmi simplicite/platform:4.0-latest-light
docker tag simplicite/platform:4.0-light-temurin-17 simplicite/platform:4.0-latest-light

docker rmi simplicite/platform:4.0-light
docker tag simplicite/platform:4.0-latest-light simplicite/platform:4.0-light

if [ $PUSH -eq 1 ]
then
	#./push-to-registries.sh --public platform 4.0-latest-light 4.0-light
	./push-to-registries.sh --delete platform \
		4.0-light-temurin-8 \
		4.0-light-temurin-11 \
		4.0-light-temurin-17 \
		4.0-light-openjdk-1.8.0 \
		4.0-light-openjdk-11 \
		4.0-latest-light \
		4.0-light
fi

exit_with
