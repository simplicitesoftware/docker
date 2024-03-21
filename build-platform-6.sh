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

[ "$1" = "" -o "$1" = "--help" ] && exit_with 1 "\nUsage: \e[1m$(basename $0)\e[0m <alpha|beta|preview|latest> [<additional tags, e.g. 6.x 6.x.y\>]\n" 

TARGET=$1
shift

# -------------------------------------------------------------------------------------------
# Current version
# -------------------------------------------------------------------------------------------

if [ "$TARGET" = "latest" ]
then
	./build-platform.sh --delete 6-latest || exit_with $? "Unable to build platform version 6-latest"

	docker rmi $REGISTRY/platform:6-latest > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-latest-almalinux9-21 $REGISTRY/platform:6-latest
	docker rmi $REGISTRY/platform:6-latest-almalinux9-21

	docker rmi $REGISTRY/platform:6-latest-jre > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-latest-almalinux9-21-jre $REGISTRY/platform:6-latest-jre
	docker rmi $REGISTRY/platform:6-latest-almalinux9-21-jre

	docker rmi $REGISTRY/platform:6-latest-jvmless > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-latest-almalinux9-jvmless $REGISTRY/platform:6-latest-jvmless
	docker rmi $REGISTRY/platform:6-latest-almalinux9-jvmless

	docker rmi $REGISTRY/platform:6 $REGISTRY/platform:latest > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-latest $REGISTRY/platform:6
	docker tag $REGISTRY/platform:6-latest $REGISTRY/platform:latest

	if [ $PUSH -eq 1 ]
	then
		./push-to-registries.sh --delete platform \
			6-latest-alpine \
			6-latest-jre \
			6-latest-jvmless \
			6 \
			latest
		./push-to-registries.sh platform 6-latest
	fi

	# All additional tags
	for TAG in $@
	do
		docker rmi $REGISTRY/platform:$TAG > /dev/null 2>&1
		docker tag $REGISTRY/platform:6-latest $REGISTRY/platform:$TAG

		if [ $PUSH -eq 1 ]
		then
			./push-to-registries.sh --delete platform $TAG
		fi
	done

	./build-platform.sh --delete 6-latest-light || exit_with $? "Unable to build platform version 6-latest-light"

	docker rmi $REGISTRY/platform:6-latest-light > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-latest-light-almalinux9-21 $REGISTRY/platform:6-latest-light
	docker rmi $REGISTRY/platform:6-latest-light-almalinux9-21

	docker rmi $REGISTRY/platform:6-latest-light-jre > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-latest-light-almalinux9-21-jre $REGISTRY/platform:6-latest-light-jre
	docker rmi $REGISTRY/platform:6-latest-light-almalinux9-21-jre

	docker rmi $REGISTRY/platform:6-latest-light-jvmless > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-latest-light-almalinux9-jvmless $REGISTRY/platform:6-latest-light-jvmless
	docker rmi $REGISTRY/platform:6-latest-light-almalinux9-jvmless

	docker rmi $REGISTRY/platform:6-light $REGISTRY/platform:latest-light > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-latest-light $REGISTRY/platform:6-light
	docker tag $REGISTRY/platform:6-latest-light $REGISTRY/platform:latest-light

	if [ $PUSH -eq 1 ]
	then
		./push-to-registries.sh --delete platform \
			6-latest-light \
			6-latest-light-alpine \
			6-latest-light-jre \
			6-latest-light-jvmless \
			6-light \
			latest-light
		./push-to-registries.sh platform 6-latest-light
	fi

	# First additional tag only
	for TAG in $2
	do
		docker rmi $REGISTRY/platform:$TAG-light > /dev/null 2>&1
		docker tag $REGISTRY/platform:6-latest-light $REGISTRY/platform:$TAG-light

		if [ $PUSH -eq 1 ]
		then
			./push-to-registries.sh --delete platform $TAG-light
		fi
	done
	docker rmi $REGISTRY/platform:6-latest-light
fi

# -------------------------------------------------------------------------------------------
# Preview version
# -------------------------------------------------------------------------------------------

if [ "$TARGET" = "preview" ]
then
	./build-platform.sh --delete 6-preview || exit_with $? "Unable to build platform version 6-preview"

	docker rmi $REGISTRY/platform:6-preview > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-preview-almalinux9-21 $REGISTRY/platform:6-preview
	docker rmi $REGISTRY/platform:6-preview-almalinux9-21
fi

# -------------------------------------------------------------------------------------------
# Alpha/beta versions
# -------------------------------------------------------------------------------------------

if [ "$TARGET" = "alpha" -o "$TARGET" = "beta" ]
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

	if [ $PUSH -eq 1 ]
	then
		./push-to-registries.sh --delete platform \
			6-$TARGET-alpine \
			6-$TARGET-jre \
			6-$TARGET-jvmless
		./push-to-registries.sh platform 6-$TARGET
	fi

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

	if [ $PUSH -eq 1 ]
	then
		./push-to-registries.sh --delete platform \
			6-$TARGET-light \
			6-$TARGET-light-alpine \
			6-$TARGET-light-jre \
			6-$TARGET-light-jvmless
	fi
fi

exit_with
