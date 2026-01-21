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

[ "$1" = "" -o "$1" = "--help" ] && exit_with 1 "\nUsage: \e[1m$(basename $0)\e[0m <preview|latest|devel|6.x> [<revision (for latest and 6.x)>]\n" 

TARGET=$1
REVISION=$2

CURRENT=6.3


# -------------------------------------------------------------------------------------------
# Current version preview
# -------------------------------------------------------------------------------------------

if [ "$TARGET" = "preview" ]
then
	trace "Building platform images for $TARGET"
	./build-platform.sh --delete 6-$TARGET || exit_with $? "Unable to build platform version 6-$TARGET"
	trace "Done"

	trace "Tagging 6-$TARGET"
	docker rmi $REGISTRY/platform:6-$TARGET > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET-almalinux9-21 $REGISTRY/platform:6-$TARGET
	docker rmi $REGISTRY/platform:6-$TARGET-almalinux9-21
	trace "Done"

	trace "Tagging 6-$TARGET-jre"
	docker rmi $REGISTRY/platform:6-$TARGET-jre > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET-almalinux9-21-jre $REGISTRY/platform:6-$TARGET-jre
	docker rmi $REGISTRY/platform:6-$TARGET-almalinux9-21-jre
	trace "Done"

	if [ $PUSH -eq 1 ]
	then
		trace "Pushing tags 6-$TARGET and 6-$TARGET-jre"
		./push-to-registries.sh platform 6-$TARGET 6-$TARGET-jre
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
	./build-platform.sh --delete 6-$TARGET || exit_with $? "Unable to build platform version 6-$TARGET"
	trace "Done"

	trace "Tagging 6-$TARGET"
	docker rmi $REGISTRY/platform:6-$TARGET > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET-almalinux9-21 $REGISTRY/platform:6-$TARGET
	docker rmi $REGISTRY/platform:6-$TARGET-almalinux9-21
	trace "Done"

	trace "Tagging 6-$TARGET-jre"
	docker rmi $REGISTRY/platform:6-$TARGET-jre > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET-almalinux9-21-jre $REGISTRY/platform:6-$TARGET-jre
	docker rmi $REGISTRY/platform:6-$TARGET-almalinux9-21-jre
	trace "Done"

	trace "Tagging 6-$TARGET-jvmless"
	docker rmi $REGISTRY/platform:6-$TARGET-jvmless > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET-almalinux9-jvmless $REGISTRY/platform:6-$TARGET-jvmless
	docker rmi $REGISTRY/platform:6-$TARGET-almalinux9-jvmless
	trace "Done"

	trace "Tagging 6"
	docker rmi $REGISTRY/platform:6 > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET $REGISTRY/platform:6
	trace "Done"

	trace "Tagging $TARGET"
	docker rmi $REGISTRY/platform:$TARGET > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET $REGISTRY/platform:$TARGET
	trace "Done"

	if [ $PUSH -eq 1 ]
	then
		trace "Pushing tags 6-$TARGET[-<alpine|alpine-jre|jre|jvmless>], 6 and $TARGET"
		./push-to-registries.sh --delete platform \
			6-$TARGET-alpine \
			6-$TARGET-alpine-jre \
			6-$TARGET-jre \
			6-$TARGET-jvmless \
			6 \
			$TARGET
		./push-to-registries.sh platform 6-$TARGET
		trace "Done"
	fi

	for TAG in $CURRENT $CURRENT.$REVISION
	do
		trace "Tagging $TAG"
		docker rmi $REGISTRY/platform:$TAG > /dev/null 2>&1
		docker tag $REGISTRY/platform:6-$TARGET $REGISTRY/platform:$TAG
		trace "Done"

		if [ $TAG = "$CURRENT" ]
		then
			trace "Tagging $TAG-jre"
			docker rmi $REGISTRY/platform:$TAG-jre > /dev/null 2>&1
			docker tag $REGISTRY/platform:6-$TARGET-jre $REGISTRY/platform:$TAG-jre
			trace "Done"
		fi

		if [ $PUSH -eq 1 ]
		then
			trace "Pushing tag $TAG"
			./push-to-registries.sh --delete platform $TAG
			trace "Done"

			if [ $TAG = "$CURRENT" ]
			then
				trace "Pushing tag $TAG-jre"
				./push-to-registries.sh --delete platform $TAG-jre
				trace "Done"
			fi
		fi
	done

	trace "Building platform images for $TARGET-light"
	./build-platform.sh --delete 6-$TARGET-light || exit_with $? "Unable to build platform version 6-$TARGET-light"
	trace "Done"

	trace "Tagging 6-$TARGET-light"
	docker rmi $REGISTRY/platform:6-$TARGET-light > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET-light-almalinux9-21 $REGISTRY/platform:6-$TARGET-light
	docker rmi $REGISTRY/platform:6-$TARGET-light-almalinux9-21
	trace "Done"

	trace "Tagging 6-$TARGET-light-jre"
	docker rmi $REGISTRY/platform:6-$TARGET-light-jre > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET-light-almalinux9-21-jre $REGISTRY/platform:6-$TARGET-light-jre
	docker rmi $REGISTRY/platform:6-$TARGET-light-almalinux9-21-jre
	trace "Done"

	trace "Tagging 6-$TARGET-jvmless"
	docker rmi $REGISTRY/platform:6-$TARGET-light-jvmless > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET-light-almalinux9-jvmless $REGISTRY/platform:6-$TARGET-light-jvmless
	docker rmi $REGISTRY/platform:6-$TARGET-light-almalinux9-jvmless
	trace "Done"

	trace "Tagging 6-light"
	docker rmi $REGISTRY/platform:6-light > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET-light $REGISTRY/platform:6-light
	trace "Done"

	trace "Tagging $TARGET-light"
	docker rmi $REGISTRY/platform:$TARGET-light > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET-light $REGISTRY/platform:$TARGET-light
	trace "Done"

	if [ $PUSH -eq 1 ]
	then
		trace "Pushing tags 6-$TARGET-light[-<alpine|alpine-jre|jre|jvmless>], 6-light and $TARGET-light"
		./push-to-registries.sh --delete platform \
			6-$TARGET-light-alpine \
			6-$TARGET-light-alpine-jre \
			6-$TARGET-light-jre \
			6-$TARGET-light-jvmless \
			6-light \
			$TARGET-light
		./push-to-registries.sh platform 6-$TARGET-light
		trace "Done"
	fi

	for TAG in $CURRENT $CURRENT.$REVISION
	do
		trace "Tagging $TAG-light"
		docker rmi $REGISTRY/platform:$TAG-light > /dev/null 2>&1
		docker tag $REGISTRY/platform:6-$TARGET-light $REGISTRY/platform:$TAG-light
		trace "Done"

		if [ $TAG = "$CURRENT" ]
		then
			trace "Tagging $TAG-light-jre"
			docker rmi $REGISTRY/platform:$TAG-light-jre > /dev/null 2>&1
			docker tag $REGISTRY/platform:6-$TARGET-light-jre $REGISTRY/platform:$TAG-light-jre
			trace "Done"
		fi

		if [ $PUSH -eq 1 ]
		then
			trace "Pushing tag $TAG-light"
			./push-to-registries.sh --delete platform $TAG-light
			trace "Done"

			if [ $TAG = "$CURRENT" ]
			then
				trace "Pushing tag $TAG-light-jre"
				./push-to-registries.sh --delete platform $TAG-light-jre
				trace "Done"
			fi
		fi
	done

	exit_with
fi

if [ "$TARGET" = "devel" ]
then
	trace "Building platform images for $TARGET"
	./build-platform.sh --delete 6-$TARGET || exit_with $? "Unable to build platform version 6-$TARGET"
	trace "Done"

	exit_with
fi

# -------------------------------------------------------------------------------------------
# Previous versions
# -------------------------------------------------------------------------------------------

if [ "$TARGET" = "6.0" -o "$TARGET" = "6.1" -o "$TARGET" = "6.2" ]
then
	[ -z "$REVISION" ] && exit_with 2 "Missing revision for $TARGET"

	trace "Building platform images for $TARGET and $TARGET-light"
	./build-platform.sh --delete $TARGET || exit_with $? "Unable to build platform version $TARGET"
	./build-platform.sh --delete $TARGET-light || exit_with $? "Unable to build platform version $TARGET-light"
	trace "Done"

	trace "Tagging $TARGET"
	docker rmi $REGISTRY/platform:$TARGET > /dev/null 2>&1
	docker tag $REGISTRY/platform:$TARGET-almalinux9-21 $REGISTRY/platform:$TARGET
	docker rmi $REGISTRY/platform:$TARGET-almalinux9-21
	trace "Done"

	trace "Tagging $TARGET-light"
	docker rmi $REGISTRY/platform:$TARGET-light > /dev/null 2>&1
	docker tag $REGISTRY/platform:$TARGET-light-almalinux9-21 $REGISTRY/platform:$TARGET-light
	docker rmi $REGISTRY/platform:$TARGET-light-almalinux9-21
	trace "Done"

	if [ $PUSH -eq 1 ]
	then
		trace "Pushing tags $TARGET and $TARGET-light"
		./push-to-registries.sh platform $TARGET
		./push-to-registries.sh --delete platform $TARGET-light
		trace "Done"
	fi

	if [ "$TARGET" = "6.2" ]
	then
		trace "Tagging $TARGET-jre"
		docker rmi $REGISTRY/platform:$TARGET-jre > /dev/null 2>&1
		docker tag $REGISTRY/platform:$TARGET-almalinux9-21 $REGISTRY/platform:$TARGET-jre
		docker rmi $REGISTRY/platform:$TARGET-almalinux9-21-jre
		trace "Done"
	
		trace "Tagging $TARGET-light-jre"
		docker rmi $REGISTRY/platform:$TARGET-light-jre > /dev/null 2>&1
		docker tag $REGISTRY/platform:$TARGET-light-almalinux9-21 $REGISTRY/platform:$TARGET-light-jre
		docker rmi $REGISTRY/platform:$TARGET-light-almalinux9-21-jre
		trace "Done"

		if [ $PUSH -eq 1 ]
		then
			trace "Pushing tags $TARGET-jre and $TARGET-light-jre"
			./push-to-registries.sh --delete platform $TARGET-jre platform $TARGET-light-jre
			trace "Done"
		fi
	fi

	for TAG in $CURRENT.$REVISION
	do
		trace "Tagging $TAG"
		docker rmi $REGISTRY/platform:$TAG > /dev/null 2>&1
		docker tag $REGISTRY/platform:$TARGET $REGISTRY/platform:$TAG
		trace "Done"

		trace "Tagging $TAG-light"
		docker rmi $REGISTRY/platform:$TAG-light > /dev/null 2>&1
		docker tag $REGISTRY/platform:$TARGET-light $REGISTRY/platform:$TAG-light
		trace "Done"

		if [ $PUSH -eq 1 ]
		then
			trace "Pushing tags $TAG and $TAG-light"
			./push-to-registries.sh --delete platform $TAG $TAG-light
			trace "Done"
		fi
	done

	exit_with
fi

exit_with 1 "Unknown target $TARGET"
