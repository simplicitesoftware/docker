#!/bin/bash

exit_with () {
	[ "$2" != "" ] && echo -e $2 >&2
	exit ${1:-0}
}

trace () {
	printf "\n\e[1;33m+------------------------------------------------------------------------------+\n| %-76s |\n+------------------------------------------------------------------------------+\e[00m\n\n" "$1"
}

REGISTRY=registry.simplicite.io

PUSH=1
if [ "$1" = "--no-push" ]
then
	PUSH=0
	shift
fi

[ "$1" = "" -o "$1" = "--help" ] && exit_with 1 "\nUsage: \e[1m$(basename $0)\e[0m <preview|latest|devel|5.x> [<revision (for latest and 6.x)>]\n" 

TARGET=$1
REVISION=$2

CURRENT=5.3

# -------------------------------------------------------------------------------------------
# Preview version
# -------------------------------------------------------------------------------------------

if [ "$TARGET" = "preview" ]
then
	trace "Building platform images for $TARGET"
	./build-platform.sh --delete 5-$TARGET || exit_with $? "Unable to build platform version 5-$TARGET"
	trace "Done"

	trace "Tagging 5-$TARGET"
	docker rmi $REGISTRY/platform:5-$TARGET > /dev/null 2>&1
	docker tag $REGISTRY/platform:5-$TARGET-almalinux9-17 $REGISTRY/platform:5-$TARGET
	docker rmi $REGISTRY/platform:5-$TARGET-almalinux9-17
	trace "Done"

	if [ $PUSH -eq 1 ]
	then
		trace "Pushing tag 5-$TARGET"
		./push-to-registries.sh platform 5-$TARGET
		trace "Done"
	fi

	exit_with
fi

# -------------------------------------------------------------------------------------------
# Current version
# -------------------------------------------------------------------------------------------

if [ "$TARGET" = "latest" -o "$TARGET" = "$CURRENT" ]
then
	TARGET=latest
	[ -z "$REVISION" ] && exit_with 2 "Missing revision for $CURRENT"

	trace "Building platform images for $TARGET"
	./build-platform.sh --delete 5-$TARGET || exit_with $? "Unable to build platform version 5-$TARGET"
	trace "Done"

	trace "Tagging 5-$TARGET"
	docker rmi $REGISTRY/platform:5-$TARGET > /dev/null 2>&1
	docker tag $REGISTRY/platform:5-$TARGET-almalinux9-17 $REGISTRY/platform:5-$TARGET
	docker rmi $REGISTRY/platform:5-$TARGET-almalinux9-17
	trace "Done"

	trace "Tagging 5-$TARGET-jre"
	docker rmi $REGISTRY/platform:5-$TARGET-jre > /dev/null 2>&1
	docker tag $REGISTRY/platform:5-$TARGET-almalinux9-17-jre $REGISTRY/platform:5-$TARGET-jre
	docker rmi $REGISTRY/platform:5-$TARGET-almalinux9-17-jre
	trace "Done"

	trace "Tagging 5-$TARGET-jvmless"
	docker rmi $REGISTRY/platform:5-$TARGET-jvmless > /dev/null 2>&1
	docker tag $REGISTRY/platform:5-$TARGET-almalinux9-jvmless $REGISTRY/platform:5-$TARGET-jvmless
	docker rmi $REGISTRY/platform:5-$TARGET-almalinux9-jvmless
	trace "Done"

	trace "Tagging 5"
	docker rmi $REGISTRY/platform:5 > /dev/null 2>&1
	docker tag $REGISTRY/platform:5-$TARGET $REGISTRY/platform:5
	trace "Done"

	if [ $PUSH -eq 1 ]
	then
		trace "Pushing tags 5-$TARGET[-<alpine|alpine-jre|jre|jvmless>], 5 and $TARGET"
		./push-to-registries.sh --delete platform \
			5-$TARGET-alpine \
			5-$TARGET-alpine-jre \
			5-$TARGET-jre \
			5-$TARGET-jvmless \
			5
		./push-to-registries.sh platform 5-$TARGET
		trace "Done"
	fi

	for TAG in $CURRENT $CURRENT.$REVISION
	do
		trace "Tagging $TAG"
		docker rmi $REGISTRY/platform:$TAG > /dev/null 2>&1
		docker tag $REGISTRY/platform:5-$TARGET $REGISTRY/platform:$TAG
		trace "Done"

		if [ $PUSH -eq 1 ]
		then
			trace "Pushing tag $TAG"
			./push-to-registries.sh --delete platform $TAG
			trace "Done"
		fi
	done

	./build-platform.sh --delete 5-$TARGET-light || exit_with $? "Unable to build platform version 5-$TARGET-light"
	trace "Done"

	trace "Tagging 5-$TARGET-light"
	docker rmi $REGISTRY/platform:5-$TARGET-light > /dev/null 2>&1
	docker tag $REGISTRY/platform:5-$TARGET-light-almalinux9-17 $REGISTRY/platform:5-$TARGET-light
	docker rmi $REGISTRY/platform:5-$TARGET-light-almalinux9-17
	trace "Done"

	trace "Tagging 5-$TARGET-light-jre"
	docker rmi $REGISTRY/platform:5-$TARGET-light-jre > /dev/null 2>&1
	docker tag $REGISTRY/platform:5-$TARGET-light-almalinux9-17-jre $REGISTRY/platform:5-$TARGET-light-jre
	docker rmi $REGISTRY/platform:5-$TARGET-light-almalinux9-17-jre
	trace "Done"

	trace "Tagging 5-$TARGET-light-jvmless"
	docker rmi $REGISTRY/platform:5-$TARGET-light-jvmless > /dev/null 2>&1
	docker tag $REGISTRY/platform:5-$TARGET-light-almalinux9-jvmless $REGISTRY/platform:5-$TARGET-light-jvmless
	docker rmi $REGISTRY/platform:5-$TARGET-light-almalinux9-jvmless
	trace "Done"

	trace "Tagging 5-light"
	docker rmi $REGISTRY/platform:5-light > /dev/null 2>&1
	docker tag $REGISTRY/platform:5-$TARGET-light $REGISTRY/platform:5-light
	trace "Done"

	if [ $PUSH -eq 1 ]
	then
		trace "Pushing tags 5-$TARGET-light[-<alpine|alpine-jre|jre|jvmless>], 5 and $TARGET"
		./push-to-registries.sh --delete platform \
			5-$TARGET-light-alpine \
			5-$TARGET-light-alpine-jre \
			5-$TARGET-light-jre \
			5-$TARGET-light-jvmless \
			5-light
		./push-to-registries.sh platform 5-$TARGET-light
		trace "Done"
	fi

	for TAG in $CURRENT $CURRENT.$REVISION
	do
		trace "Tagging $TAG-light"
		docker rmi $REGISTRY/platform:$TAG-light > /dev/null 2>&1
		docker tag $REGISTRY/platform:5-$TARGET-light $REGISTRY/platform:$TAG-light
		trace "Done"

		if [ $PUSH -eq 1 ]
		then
			trace "Pushing tag $TAG-light"
			./push-to-registries.sh --delete platform $TAG-light
			trace "Done"
		fi
	done

	exit_with
fi

if [ "$TARGET" = "devel" ]
then
	trace "Building platform images for $TARGET"
	./build-platform.sh --delete 5-$TARGET || exit_with $? "Unable to build platform version 5-$TARGET"
	trace "Done"

	exit_with
fi

# -------------------------------------------------------------------------------------------
# Previous versions
# -------------------------------------------------------------------------------------------

if [ "$TARGET" = "5.0" -o "$TARGET" = "5.1" -o "$TARGET" = "5.2" ]
then
	[ -z "$REVISION" ] && exit_with 2 "Missing revision for $TARGET"

	./build-platform.sh --delete $TARGET || exit_with $? "Unable to build platform version $TARGET"
	./build-platform.sh --delete $TARGET-light || exit_with $? "Unable to build platform version $TARGET-light"

	trace "Tagging $TARGET"
	docker rmi $REGISTRY/platform:$TARGET > /dev/null 2>&1
	docker tag $REGISTRY/platform:$TARGET-almalinux9-17 $REGISTRY/platform:$TARGET
	docker rmi $REGISTRY/platform:$TARGET-almalinux9-17
	trace "Done"

	trace "Tagging $TARGET-light"
	docker rmi $REGISTRY/platform:$TARGET-light > /dev/null 2>&1
	docker tag $REGISTRY/platform:$TARGET-light-almalinux9-17 $REGISTRY/platform:$TARGET-light
	docker rmi $REGISTRY/platform:$TARGET-light-almalinux9-17
	trace "Done"

	if [ $PUSH -eq 1 ]
	then
		./push-to-registries.sh platform $TARGET
		./push-to-registries.sh --delete platform $TARGET-light
		trace "Done"
	fi

	for TAG in $CURRENT.$REVISION
	do
		trace "Tagging $TAG"
		docker rmi $REGISTRY/platform:$TAG > /dev/null 2>&1
		docker tag $REGISTRY/platform:$TARGET $REGISTRY/platform:$TAG
		trace "Done"

		if [ $PUSH -eq 1 ]
		then
			trace "Pushing tag $TAG"
			./push-to-registries.sh --delete platform $TAG
			trace "Done"
		fi
	done

	exit_with
fi

exit_with 1 "Unknown target $TARGET"
