#!/bin/bash

if [ "$1" = "" -o "$1" = "--help" ]
then
	echo "Usage: `basename $0` <all|alpha|devel|beta|latest> [<additional tags for latest, e.g. \"5.x 5.x.y\">]" >&2 
	exit -1
fi

if [ "$1" = "alpha" -o "$1" = "all" ]
then
	./build-platform.sh --delete 5-alpha

	# ZZZ temporary
	docker rmi simplicite/platform:5-alpha
	docker tag simplicite/platform:5-alpha-temurin-17 simplicite/platform:5-alpha
	# ZZZ temporary

	./push-to-registries.sh platform \
		5-alpha-temurin-17 \
		5-alpha-temurin-17-jre \
		5-alpha

	./build-platform.sh --delete 5-alpha-light

	# ZZZ temporary
	docker rmi simplicite/platform:5-alpha-light
	docker tag simplicite/platform:5-alpha-light-temurin-17 simplicite/platform:5-alpha-light
	# ZZZ temporary

	./push-to-registries.sh platform \
		5-alpha-light-temurin-17 \
		5-alpha-light-temurin-17-jre \
		5-alpha-light

	./build-platform.sh --delete 5-alpha-test

	./push-to-registries.sh platform \
		5-alpha-test-centos8 \
		5-alpha-test-rockylinux \
		5-alpha-test-almalinux \
		5-alpha-test-adoptium-17 \
		5-alpha-test-adoptium-11 \
		5-alpha-test-alpine \
		5-alpha-test-alpine-temurin
fi

if [ "$1" = "devel" ]
then
	./build-platform.sh --delete 5-devel
fi

if [ "$1" = "beta" -o "$1" = "all" ]
then
	./build-platform.sh --delete 5-beta

	# ZZZ temporary
	docker rmi simplicite/platform:5-beta
	docker tag simplicite/platform:5-beta-temurin-17 simplicite/platform:5-beta
	# ZZZ temporary

	./push-to-registries.sh platform \
		5-beta-temurin-17 \
		5-beta-temurin-17-jre \
		5-beta

	./build-platform.sh --delete 5-beta-light

	# ZZZ temporary
	docker rmi simplicite/platform:5-beta-light
	docker tag simplicite/platform:5-beta-light-temurin-17 simplicite/platform:5-beta-light
	# ZZZ temporary

	./push-to-registries.sh platform \
		5-beta-light-temurin-17 \
		5-beta-light-temurin-17-jre \
		5-beta-light
fi

if [ "$1" = "latest" -o "$1" = "all" ]
then
	./build-platform.sh --delete 5-latest

	# ZZZ temporary
	docker rmi simplicite/platform:5-latest
	docker tag simplicite/platform:5-latest-temurin-17 simplicite/platform:5-latest
	# ZZZ temporary

	docker rmi simplicite/platform:5 simplicite/platform:latest
	docker tag simplicite/platform:5-latest simplicite/platform:5
	docker tag simplicite/platform:5-latest simplicite/platform:latest

	./push-to-registries.sh platform \
		5-latest-jvmless \
		5-latest-temurin-11 \
		5-latest-temurin-17 \
		5-latest-temurin-17-jre \
		5-latest-openjdk-11 \
		5-latest-openjdk-17 \
		5-latest \
		5 \
		latest

	./build-platform.sh --delete 5-latest-light

	# ZZZ temporary
	docker rmi simplicite/platform:5-latest-light
	docker tag simplicite/platform:5-latest-light-temurin-17 simplicite/platform:5-latest-light
	# ZZZ temporary

	docker rmi simplicite/platform:5-light simplicite/platform:latest-light
	docker tag simplicite/platform:5-latest-light simplicite/platform:5-light
	docker tag simplicite/platform:5-latest-light simplicite/platform:latest-light

	./push-to-registries.sh platform \
		5-latest-light-jvmless \
		5-latest-light-temurin-11 \
		5-latest-light-temurin-17 \
		5-latest-light-temurin-17-jre \
		5-latest-light-openjdk-11 \
		5-latest-light-openjdk-17 \
		5-latest-light \
		5-light \
		latest-light

	# Additional tags
	for TAG in ${@:2}
	do
		docker rmi simplicite/platform:$TAG simplicite/platform:$TAG-light
		docker tag simplicite/platform:5-latest simplicite/platform:$TAG
		docker tag simplicite/platform:5-latest-light simplicite/platform:$TAG-light

		./push-to-registries.sh platform $TAG $TAG-light
	done
fi

# Legacy versions

if [ "$1" = "5.0" ]
then
	./build-platform.sh --delete 5.0
	./build-platform.sh --delete 5.0-light

	./push-to-registries.sh platform \
		5.0 \
		5.0-light
fi

exit 0
