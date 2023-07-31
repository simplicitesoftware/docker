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

	docker rmi $REGISTRY/platform:6-alpha > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-alpha-adoptium-17 $REGISTRY/platform:6-alpha
	docker rmi $REGISTRY/platform:6-alpha-adoptium-17

	docker rmi $REGISTRY/platform:6-latest-jre > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-latest-adoptium-17-jre $REGISTRY/platform:6-latest-jre
	docker rmi $REGISTRY/platform:6-latest-adoptium-17-jre

	if [ $PUSH -eq 1 ]
	then
		./push-to-registries.sh --delete platform \
			6-alpha-alpine \
			6-alpha-jre \
			6-alpha-jvmless \
			6-alpha
	fi

	./build-platform.sh --delete 6-alpha-light || exit_with $? "Unable to build platform version 6-alpha-light"

	docker rmi $REGISTRY/platform:6-alpha-light > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-alpha-light-adoptium-17 $REGISTRY/platform:6-alpha-light
	docker rmi $REGISTRY/platform:6-alpha-light-adoptium-17

	docker rmi $REGISTRY/platform:6-latest-light-jre > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-latest-light-adoptium-17-jre $REGISTRY/platform:6-latest-light-jre
	docker rmi $REGISTRY/platform:6-latest-light-adoptium-17-jre

	if [ $PUSH -eq 1 ]
	then
		./push-to-registries.sh --delete platform \
			6-alpha-light-alpine \
			6-alpha-light-jre \
			6-alpha-light-jvmless \
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
