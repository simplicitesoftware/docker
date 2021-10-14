#!/bin/bash

./build-platform.sh --delete 4.0-latest

# ZZZ temporary
docker rmi simplicite/platform:4.0-latest
docker tag simplicite/platform:4.0-latest-temurin-17 simplicite/platform:4.0-latest
# ZZZ temporary

docker rmi simplicite/platform:4.0
docker tag simplicite/platform:4.0-latest simplicite/platform:4.0

./push-to-registries.sh platform \
	4.0-latest-adoptium-11 4.0-latest-adoptium-17 \
	4.0-latest-temurin-11 4.0-latest-temurin-17 \
	4.0-latest-openjdk-11 \
	4.0-latest 4.0

./build-platform.sh --delete 4.0-latest-light

# ZZZ temporary
docker rmi simplicite/platform:4.0-latest-light
docker tag simplicite/platform:4.0-latest-light-temurin-17 simplicite/platform:4.0-latest-light
# ZZZ temporary

docker rmi simplicite/platform:4.0-light
docker tag simplicite/platform:4.0-latest-light simplicite/platform:4.0-light

./push-to-registries.sh platform \
	4.0-latest-light-adoptium-8 4.0-latest-light-adoptium-11 4.0-latest-light-adoptium-17 \
	4.0-latest-light-temurin-11 4.0-latest-light-temurin-17 \
	4.0-latest-light-openjdk-1.8.0 4.0-latest-light-openjdk-11 \
	4.0-latest-light 4.0-light

exit 0
