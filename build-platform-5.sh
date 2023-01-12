#!/bin/bash

exit_with () {
	[ "$2" != "" ] && echo -e $2 >&2
	exit ${1:-0}
}

[ "$1" = "" -o "$1" = "--help" ] && exit_with 1 "\nUsage: \e[1m$(basename $0)\e[0m <all|alpha|devel|beta|latest> [<additional tags for latest, e.g. \"5.x 5.x.y\">]\n" 

if [ "$1" = "alpha" -o "$1" = "all" ]
then
	./build-platform.sh --delete 5-alpha || exit_with $? "Unable to build platform version 5-alpha"

	# ZZZ temporary
	docker rmi simplicite/platform:5-alpha
	docker tag simplicite/platform:5-alpha-temurin-17 simplicite/platform:5-alpha
	# ZZZ temporary

	./push-to-registries.sh --delete platform \
		5-alpha-temurin-17 \
		5-alpha-temurin-17-jre \
		5-alpha-alpine
	./push-to-registries.sh platform 5-alpha

	./build-platform.sh --delete 5-alpha-light || exit_with $? "Unable to build platform version 5-alpha-light"

	# ZZZ temporary
	docker rmi simplicite/platform:5-alpha-light
	docker tag simplicite/platform:5-alpha-light-temurin-17 simplicite/platform:5-alpha-light
	# ZZZ temporary

	./push-to-registries.sh --delete platform \
		5-alpha-light-temurin-17 \
		5-alpha-light-temurin-17-jre \
		5-alpha-light \
		5-alpha-light-alpine

	# Additional tags
	for TAG in ${@:2}
	do
		docker rmi simplicite/platform:$TAG simplicite/platform:$TAG-light
		docker tag simplicite/platform:5-alpha simplicite/platform:$TAG
		docker tag simplicite/platform:5-alpha-light simplicite/platform:$TAG-light

		./push-to-registries.sh --delete platform $TAG $TAG-light
	done
fi

if [ "$1" = "devel" ]
then
	./build-platform.sh --delete 5-devel
fi

if [ "$1" = "beta" -o "$1" = "all" ]
then
	./build-platform.sh --delete 5-beta || exit_with $? "Unable to build platform version 5-beta"

	# ZZZ temporary
	docker rmi simplicite/platform:5-beta
	docker tag simplicite/platform:5-beta-temurin-17 simplicite/platform:5-beta
	# ZZZ temporary

	./push-to-registries.sh --delete platform \
		5-beta-temurin-17 \
		5-beta-temurin-17-jre \
		5-beta-alpine
	./push-to-registries.sh platform 5-beta

	./build-platform.sh --delete 5-beta-light || exit_with $? "Unable to build platform version 5-beta-light"

	# ZZZ temporary
	docker rmi simplicite/platform:5-beta-light
	docker tag simplicite/platform:5-beta-light-temurin-17 simplicite/platform:5-beta-light
	# ZZZ temporary

	./push-to-registries.sh --delete platform \
		5-beta-light-temurin-17 \
		5-beta-light-temurin-17-jre \
		5-beta-light \
		5-beta-light-alpine

	# Additional tags
	for TAG in ${@:2}
	do
		docker rmi simplicite/platform:$TAG simplicite/platform:$TAG-light
		docker tag simplicite/platform:5-beta simplicite/platform:$TAG
		docker tag simplicite/platform:5-beta-light simplicite/platform:$TAG-light

		./push-to-registries.sh --delete platform $TAG $TAG-light
	done
fi

if [ "$1" = "latest" -o "$1" = "all" ]
then
	./build-platform.sh --delete 5-latest || exit_with $? "Unable to build platform version 5-latest"

	# ZZZ temporary
	docker rmi simplicite/platform:5-latest
	docker tag simplicite/platform:5-latest-temurin-17 simplicite/platform:5-latest
	# ZZZ temporary

	docker rmi simplicite/platform:5 simplicite/platform:latest
	docker tag simplicite/platform:5-latest simplicite/platform:5
	docker tag simplicite/platform:5-latest simplicite/platform:latest

	./push-to-registries.sh --delete platform \
		5-latest-jvmless \
		5-latest-temurin-11 \
		5-latest-temurin-17 \
		5-latest-temurin-17-jre \
		5-latest-alpine \
		5 \
		latest
	./push-to-registries.sh platform 5-latest

	./build-platform.sh --delete 5-latest-light || exit_with $? "Unable to build platform version 5-latest-light"

	# ZZZ temporary
	docker rmi simplicite/platform:5-latest-light
	docker tag simplicite/platform:5-latest-light-temurin-17 simplicite/platform:5-latest-light
	# ZZZ temporary

	docker rmi simplicite/platform:5-light simplicite/platform:latest-light
	docker tag simplicite/platform:5-latest-light simplicite/platform:5-light
	docker tag simplicite/platform:5-latest-light simplicite/platform:latest-light

	./push-to-registries.sh --delete platform \
		5-latest-light-jvmless \
		5-latest-light-temurin-11 \
		5-latest-light-temurin-17 \
		5-latest-light-temurin-17-jre \
		5-latest-light-alpine \
		5-latest-light \
		5-light \
		latest-light

	# Additional tags
	for TAG in ${@:2}
	do
		docker rmi simplicite/platform:$TAG
		docker tag simplicite/platform:5-latest simplicite/platform:$TAG

		./push-to-registries.sh --delete platform $TAG
	done
fi

# Experimental builds

if [ "$1" = "latest-test" -o "$1" = "all" ]
then
	./build-platform.sh --delete 5-latest-test || exit_with $? "Unable to build platform version 5-latest-test"

	./push-to-registries.sh --delete platform \
		5-latest-test-rockylinux \
		5-latest-test-almalinux \
		5-latest-test-adoptium-17 \
		5-latest-test-adoptium-11
fi

# Previous minor versions

if [ "$1" = "5.0" -o "$1" = "5.1" ]
then
	./build-platform.sh --delete $1 || exit_with $? "Unable to build platform version $1"
	./build-platform.sh --delete $1-light || exit_with $? "Unable to build platform version $1-light"

	# ZZZ temporary
	docker rmi simplicite/platform:$1 simplicite/platform:$1-light
	docker tag simplicite/platform:$1-temurin-17 simplicite/platform:$1
	docker tag simplicite/platform:$1-light-temurin-17 simplicite/platform:$1-light
	# ZZZ temporary

	./push-to-registries.sh --delete platform \
		$1-temurin-17 \
		$1-alpine \
		$1-light-temurin-17 \
		$1-light-alpine \
		$1-light
	./push-to-registries.sh platform $1

	# Additional tags
	for TAG in ${@:2}
	do
		docker rmi simplicite/platform:$TAG
		docker tag simplicite/platform:$1 simplicite/platform:$TAG

		./push-to-registries.sh --delete platform $TAG
	done
fi

exit_with
