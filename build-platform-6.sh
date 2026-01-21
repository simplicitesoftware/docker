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

[ "$1" = "" -o "$1" = "--help" ] && exit_with 1 "\nUsage: \e[1m$(basename $0)\e[0m <preview|latest|devel|6.2|6.1|6.0>\n" 

TARGET=$1
shift

# -------------------------------------------------------------------------------------------
# Current version preview => tags: 6-preview / 6-preview-jre
# -------------------------------------------------------------------------------------------

if [ "$TARGET" = "preview" ]
then
	./build-platform.sh --delete 6-$TARGET almalinux9-21 || exit_with $? "Unable to build platform version 6-$TARGET"

	docker rmi $REGISTRY/platform:6-$TARGET > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET-almalinux9-21 $REGISTRY/platform:6-$TARGET
	docker rmi $REGISTRY/platform:6-$TARGET-almalinux9-21

	docker rmi $REGISTRY/platform:6-$TARGET-jre > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET-almalinux9-21-jre $REGISTRY/platform:6-$TARGET-jre
	docker rmi $REGISTRY/platform:6-$TARGET-almalinux9-21-jre

	[ $PUSH -eq 1 ] && ./push-to-registries.sh platform 6-$TARGET $TARGET-jre

	exit_with
fi

# -------------------------------------------------------------------------------------------
# Current version => tags: 6-latest / 6-latest-light / 6-latest-jre / 6-latest-light-jre / 6.3 / 6.3-light / 6.3-jre / 6.3-light-jre / 6.3.x / 6.3.x-light"
# -------------------------------------------------------------------------------------------

if [ "$TARGET" = "latest" ]
then
	./build-platform.sh --delete 6-$TARGET || exit_with $? "Unable to build platform version 6-$TARGET"

	docker rmi $REGISTRY/platform:6-$TARGET > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET-almalinux9-21 $REGISTRY/platform:6-$TARGET
	docker rmi $REGISTRY/platform:6-$TARGET-almalinux9-21

	docker rmi $REGISTRY/platform:6-$TARGET-jre > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET-almalinux9-21-jre $REGISTRY/platform:6-$TARGET-jre
	docker rmi $REGISTRY/platform:6-$TARGET-almalinux9-21-jre

	docker rmi $REGISTRY/platform:6-$TARGET-jvmless > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET-almalinux9-jvmless $REGISTRY/platform:6-$TARGET-jvmless
	docker rmi $REGISTRY/platform:6-$TARGET-almalinux9-jvmless

	docker rmi $REGISTRY/platform:6 $REGISTRY/platform:$TARGET > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET $REGISTRY/platform:6
	docker tag $REGISTRY/platform:6-$TARGET $REGISTRY/platform:$TARGET

	if [ $PUSH -eq 1 ]
	then
		./push-to-registries.sh --delete platform \
			6-$TARGET-alpine \
			6-$TARGET-alpine-jre \
			6-$TARGET-jre \
			6-$TARGET-jvmless \
			6 \
			$TARGET
		./push-to-registries.sh platform 6-$TARGET
	fi

	for TAG in 6.3 $1
	do
		docker rmi $REGISTRY/platform:$TAG > /dev/null 2>&1
		docker tag $REGISTRY/platform:6-$TARGET $REGISTRY/platform:$TAG
		[ $TAG = "6.3" ] && docker tag $REGISTRY/platform:6-$TARGET-jre $REGISTRY/platform:$TAG-jre

		if [ $PUSH -eq 1 ]
		then
			./push-to-registries.sh --delete platform $TAG
			[ $TAG = "6.3" ] && ./push-to-registries.sh --delete platform $TAG-jre
		fi
	done

	./build-platform.sh --delete 6-$TARGET-light || exit_with $? "Unable to build platform version 6-$TARGET-light"

	docker rmi $REGISTRY/platform:6-$TARGET-light > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET-light-almalinux9-21 $REGISTRY/platform:6-$TARGET-light
	docker rmi $REGISTRY/platform:6-$TARGET-light-almalinux9-21

	docker rmi $REGISTRY/platform:6-$TARGET-light-jre > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET-light-almalinux9-21-jre $REGISTRY/platform:6-$TARGET-light-jre
	docker rmi $REGISTRY/platform:6-$TARGET-light-almalinux9-21-jre

	docker rmi $REGISTRY/platform:6-$TARGET-light-jvmless > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET-light-almalinux9-jvmless $REGISTRY/platform:6-$TARGET-light-jvmless
	docker rmi $REGISTRY/platform:6-$TARGET-light-almalinux9-jvmless

	docker rmi $REGISTRY/platform:6-light $REGISTRY/platform:$TARGET-light > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET-light $REGISTRY/platform:6-light
	docker tag $REGISTRY/platform:6-$TARGET-light $REGISTRY/platform:$TARGET-light

	if [ $PUSH -eq 1 ]
	then
		./push-to-registries.sh --delete platform \
			6-$TARGET-light-alpine \
			6-$TARGET-light-alpine-jre \
			6-$TARGET-light-jre \
			6-$TARGET-light-jvmless \
			6-light \
			$TARGET-light
		./push-to-registries.sh platform 6-$TARGET-light
	fi

	for TAG in 6.3 $1
	do
		docker rmi $REGISTRY/platform:$TAG-light > /dev/null 2>&1
		docker tag $REGISTRY/platform:6-$TARGET-light $REGISTRY/platform:$TAG-light
		[ $TAG = "6.3" ] && docker tag $REGISTRY/platform:6-$TARGET-light-jre $REGISTRY/platform:$TAG-light-jre

		if [ $PUSH -eq 1 ]
		then
			./push-to-registries.sh --delete platform $TAG-light
			[ $TAG = "6.3" ] && ./push-to-registries.sh --delete platform $TAG-light-jre
		fi
	done
	docker rmi $REGISTRY/platform:6-$TARGET-light

	exit_with
fi

if [ "$TARGET" = "devel" ]
then
	./build-platform.sh --delete 6-$TARGET || exit_with $? "Unable to build platform version 6-$TARGET"

	exit_with
fi

# -------------------------------------------------------------------------------------------
# Previous versions => tags: 6.x / 6.x-light / 6.x.y / 6.x.y-light (plus -jre tags for 6.2 only ZZZ temporary ZZZ)
# -------------------------------------------------------------------------------------------

if [ "$TARGET" = "6.0" -o "$TARGET" = "6.1" -o "$TARGET" = "6.2" ]
then
	./build-platform.sh --delete $TARGET || exit_with $? "Unable to build platform version $TARGET"
	./build-platform.sh --delete $TARGET-light || exit_with $? "Unable to build platform version $TARGET-light"

	docker rmi $REGISTRY/platform:$TARGET > /dev/null 2>&1
	docker tag $REGISTRY/platform:$TARGET-almalinux9-21 $REGISTRY/platform:$TARGET
	docker rmi $REGISTRY/platform:$TARGET-almalinux9-21

	docker rmi $REGISTRY/platform:$TARGET-light > /dev/null 2>&1
	docker tag $REGISTRY/platform:$TARGET-light-almalinux9-21 $REGISTRY/platform:$TARGET-light
	docker rmi $REGISTRY/platform:$TARGET-light-almalinux9-21

	if [ $PUSH -eq 1 ]
	then
		./push-to-registries.sh platform $TARGET
		./push-to-registries.sh --delete platform $TARGET-light
	fi

	for TAG in $TARGET $1
	do
		docker rmi $REGISTRY/platform:$TAG > /dev/null 2>&1
		docker tag $REGISTRY/platform:$TARGET $REGISTRY/platform:$TAG
		docker tag $REGISTRY/platform:$TARGET-light $REGISTRY/platform:$TAG-light
		# ZZZ temporary ZZZ
		if [ "$TARGET" = "6.2" ]
		then
			docker tag $REGISTRY/platform:$TARGET-jre $REGISTRY/platform:$TAG-jre
			docker tag $REGISTRY/platform:$TARGET-light-jre $REGISTRY/platform:$TAG-light-jre
		fi
		
		if [ $PUSH -eq 1 ]
		then
			./push-to-registries.sh --delete platform $TAG $TAG-light
			# ZZZ temporary ZZZ
			[ "$TARGET" = "6.2" ] && ./push-to-registries.sh --delete platform $TAG-jre $TAG-light-jre
		fi
	done

	exit_with
fi

exit_with 1 "Unknown target $TARGET"
