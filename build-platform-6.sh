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

[ "$1" = "" -o "$1" = "--help" ] && exit_with 1 "\nUsage: \e[1m$(basename $0)\e[0m <alpha|beta|latest> [<additional tags, e.g. \"6.x 6.x.y\">]\n" 

if [ "$1" = "alpha" ]
then
	./build-platform.sh --delete 6-alpha || exit_with $? "Unable to build platform version 6-alpha"

	docker rmi $REGISTRY/platform:6-alpha
	docker tag $REGISTRY/platform:6-alpha-temurin-17 $REGISTRY/platform:6-alpha

	if [ $PUSH -eq 1 ]
	then
		./push-to-registries.sh --delete platform \
			6-alpha-temurin-17 \
			6-alpha-temurin-17-jre \
			6-alpha-alpine \
			6-alpha
	fi

	./build-platform.sh --delete 6-alpha-light || exit_with $? "Unable to build platform version 6-alpha-light"

	docker rmi $REGISTRY/platform:6-alpha-light
	docker tag $REGISTRY/platform:6-alpha-light-temurin-17 $REGISTRY/platform:6-alpha-light

	if [ $PUSH -eq 1 ]
	then
		./push-to-registries.sh --delete platform \
			6-alpha-light-temurin-17 \
			6-alpha-light-temurin-17-jre \
			6-alpha-light-alpine \
			6-alpha-light
	fi
fi

if [ "$1" = "beta" ]
then
	echo "Not yet available..."
fi

if [ "$1" = "latest" ]
then
	echo "Not yet available..."
fi

exit_with
