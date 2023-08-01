#!/bin/bash

exit_with () {
	[ "$2" != "" ] && echo -e $2 >&2
	exit ${1:-0}
}

REGISTRY=registry.simplicite.io

PUSH=1
if [ "$1" = "--no-push" ]
then
	PUSH=0
	shift
fi

[ "$1" = "--help" ] && exit_with 1 "\nUsage: \e[1m$(basename $0)\e[0m\n" 

./build-platform.sh --delete 4.0 || exit_with $? "Unable to build platform version 4.0-latest"

docker rmi $REGISTRY/platform:4.0-latest > /dev/null 2>&1
docker tag $REGISTRY/platform:4.0-adoptium-17 $REGISTRY/platform:4.0-latest
docker rmi $REGISTRY/platform:4.0-adoptium-17

docker rmi $REGISTRY/platform:4.0 > /dev/null 2>&1
docker tag $REGISTRY/platform:4.0-latest $REGISTRY/platform:4.0

if [ $PUSH -eq 1 ]
then
	./push-to-registries.sh --delete platform \
	./push-to-registries.sh platform \
		4.0-latest \
		4.0
fi

./build-platform.sh --delete 4.0-light || exit_with $? "Unable to build platform version 4.0-latest-light"

docker rmi $REGISTRY/platform:4.0-latest-light > /dev/null 2>&1
docker tag $REGISTRY/platform:4.0-light-adoptium-17 $REGISTRY/platform:4.0-latest-light
docker rmi $REGISTRY/platform:4.0-light-adoptium-17

docker rmi $REGISTRY/platform:4.0-light > /dev/null 2>&1
docker tag $REGISTRY/platform:4.0-latest-light $REGISTRY/platform:4.0-light

if [ $PUSH -eq 1 ]
then
	./push-to-registries.sh --delete platform \
		4.0-latest-light \
		4.0-light
fi

exit_with
