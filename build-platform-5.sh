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

[ "$1" = "" -o "$1" = "--help" ] && exit_with 1 "\nUsage: \e[1m$(basename $0)\e[0m <beta|latest|5.x> [<additional tags, e.g. \"5.x 5.x.y\">]\n" 

if [ "$1" = "beta" ]
then
	./build-platform.sh --delete 5-beta || exit_with $? "Unable to build platform version 5-beta"

	docker rmi $REGISTRY/platform:5-beta
	docker tag $REGISTRY/platform:5-beta-adoptium-17 $REGISTRY/platform:5-beta

	if [ $PUSH -eq 1 ]
	then
		./push-to-registries.sh --delete platform \
			5-beta-adoptium-17 \
			5-beta-adoptium-17-jre \
			5-beta-alpine \
			5-beta
	fi

	./build-platform.sh --delete 5-beta-light || exit_with $? "Unable to build platform version 5-beta-light"

	docker rmi $REGISTRY/platform:5-beta-light
	docker tag $REGISTRY/platform:5-beta-light-adoptium-17 $REGISTRY/platform:5-beta-light

	if [ $PUSH -eq 1 ]
	then
		./push-to-registries.sh --delete platform \
			5-beta-light-adoptium-17 \
			5-beta-light-adoptium-17-jre \
			5-beta-light-alpine \
			5-beta-light
	fi
fi

if [ "$1" = "latest" ]
then
	./build-platform.sh --delete 5-latest || exit_with $? "Unable to build platform version 5-latest"

	docker rmi $REGISTRY/platform:5-latest
	docker tag $REGISTRY/platform:5-latest-adoptium-17 $REGISTRY/platform:5-latest

	docker rmi $REGISTRY/platform:5 $REGISTRY/platform:latest
	docker tag $REGISTRY/platform:5-latest $REGISTRY/platform:5
	docker tag $REGISTRY/platform:5-latest $REGISTRY/platform:latest

	if [ $PUSH -eq 1 ]
	then
		./push-to-registries.sh --delete platform \
			5-latest-jvmless \
			5-latest-adoptium-17 \
			5-latest-adoptium-17-jre \
			5-latest-alpine \
			5 \
			latest
		./push-to-registries.sh platform 5-latest
	fi

	# Additional tags
	for TAG in ${@:2}
	do
		docker rmi $REGISTRY/platform:$TAG
		docker tag $REGISTRY/platform:5-latest $REGISTRY/platform:$TAG

		if [ $PUSH -eq 1 ]
		then
			./push-to-registries.sh --delete platform $TAG
		fi
	done

	./build-platform.sh --delete 5-latest-light || exit_with $? "Unable to build platform version 5-latest-light"

	docker rmi $REGISTRY/platform:5-latest-light
	docker tag $REGISTRY/platform:5-latest-light-adoptium-17 $REGISTRY/platform:5-latest-light

	docker rmi $REGISTRY/platform:5-light $REGISTRY/platform:latest-light
	docker tag $REGISTRY/platform:5-latest-light $REGISTRY/platform:5-light
	docker tag $REGISTRY/platform:5-latest-light $REGISTRY/platform:latest-light

	if [ $PUSH -eq 1 ]
	then
		./push-to-registries.sh --delete platform \
			5-latest-light-jvmless \
			5-latest-light-adoptium-17 \
			5-latest-light-adoptium-17-jre \
			5-latest-light-alpine \
			5-light \
			latest-light
		./push-to-registries.sh platform 5-latest-light
	fi

	# Additional tags
	for TAG in ${@:2}
	do
		docker rmi $REGISTRY/platform:$TAG-light
		docker tag $REGISTRY/platform:5-latest-light $REGISTRY/platform:$TAG-light

		if [ $PUSH -eq 1 ]
		then
			./push-to-registries.sh --delete platform $TAG-light
		fi
	done
fi

# Experimental builds

if [ "$1" = "latest-test" ]
then
	./build-platform.sh --delete 5-latest-test || exit_with $? "Unable to build platform version 5-latest-test"

	if [ $PUSH -eq 1 ]
	then
		./push-to-registries.sh --delete platform \
			5-latest-test-rockylinux8-17 \
			5-latest-test-almalinux8-17 \
			5-latest-test-adoptium-17
	fi
fi

# Previous versions

if [ "$1" = "5.0" -o "$1" = "5.1" -o "$1" = "5.2" ]
then
	./build-platform.sh --delete $1 || exit_with $? "Unable to build platform version $1"
	./build-platform.sh --delete $1-light || exit_with $? "Unable to build platform version $1-light"

	docker rmi $REGISTRY/platform:$1 $REGISTRY/platform:$1-light
	docker tag $REGISTRY/platform:$1-adoptium-17 $REGISTRY/platform:$1
	docker tag $REGISTRY/platform:$1-light-adoptium-17 $REGISTRY/platform:$1-light

	if [ $PUSH -eq 1 ]
	then
		./push-to-registries.sh --delete platform \
			$1-adoptium-17 \
			$1-alpine \
			$1-light-adoptium-17 \
			$1-light-alpine \
			$1-light
		./push-to-registries.sh platform $1
	fi

	# Additional tags
	for TAG in ${@:2}
	do
		docker rmi $REGISTRY/platform:$TAG
		docker tag $REGISTRY/platform:$1 $REGISTRY/platform:$TAG

		if [ $PUSH -eq 1 ]
		then
			./push-to-registries.sh --delete platform $TAG
		fi
	done
fi

exit_with
