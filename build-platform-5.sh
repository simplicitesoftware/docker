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

[ "$1" = "" -o "$1" = "--help" ] && exit_with 1 "\nUsage: \e[1m$(basename $0)\e[0m <preview|latest|5.x> [<additional tags, e.g. \"5.x 5.x.y\">]\n" 

TARGET=$1
shift

# -------------------------------------------------------------------------------------------
# Preview version
# -------------------------------------------------------------------------------------------

if [ "$TARGET" = "preview" ]
then
	./build-platform.sh --delete 5-preview || exit_with $? "Unable to build platform version 5-preview"

	docker rmi $REGISTRY/platform:5-preview > /dev/null 2>&1
	docker tag $REGISTRY/platform:5-preview-centos-17 $REGISTRY/platform:5-preview
	docker rmi $REGISTRY/platform:5-preview-centos-17
fi

# -------------------------------------------------------------------------------------------
# Current version
# -------------------------------------------------------------------------------------------

if [ "$TARGET" = "latest" ]
then
	./build-platform.sh --delete 5-latest || exit_with $? "Unable to build platform version 5-latest"

	docker rmi $REGISTRY/platform:5-latest > /dev/null 2>&1
	docker tag $REGISTRY/platform:5-latest-centos-17 $REGISTRY/platform:5-latest
	docker rmi $REGISTRY/platform:5-latest-centos-17

	docker rmi $REGISTRY/platform:5-latest-jre > /dev/null 2>&1
	docker tag $REGISTRY/platform:5-latest-centos-17-jre $REGISTRY/platform:5-latest-jre
	docker rmi $REGISTRY/platform:5-latest-centos-17-jre

	docker rmi $REGISTRY/platform:5-latest-jvmless > /dev/null 2>&1
	docker tag $REGISTRY/platform:5-latest-centos-jvmless $REGISTRY/platform:5-latest-jvmless
	docker rmi $REGISTRY/platform:5-latest-centos-jvmless

	docker rmi $REGISTRY/platform:5 > /dev/null 2>&1
	docker tag $REGISTRY/platform:5-latest $REGISTRY/platform:5

	if [ $PUSH -eq 1 ]
	then
		./push-to-registries.sh --delete platform \
			5-latest-alpine \
			5-latest-jvmless \
			5-latest-jre \
			5
		./push-to-registries.sh platform 5-latest
	fi

	# All additional tags
	for TAG in $@
	do
		docker rmi $REGISTRY/platform:$TAG > /dev/null 2>&1
		docker tag $REGISTRY/platform:5-latest $REGISTRY/platform:$TAG

		if [ $PUSH -eq 1 ]
		then
			./push-to-registries.sh --delete platform $TAG
		fi
	done

	./build-platform.sh --delete 5-latest-light || exit_with $? "Unable to build platform version 5-latest-light"

	docker rmi $REGISTRY/platform:5-latest-light > /dev/null 2>&1
	docker tag $REGISTRY/platform:5-latest-light-centos-17 $REGISTRY/platform:5-latest-light
	docker rmi $REGISTRY/platform:5-latest-light-centos-17

	docker rmi $REGISTRY/platform:5-latest-light-jre > /dev/null 2>&1
	docker tag $REGISTRY/platform:5-latest-light-centos-17-jre $REGISTRY/platform:5-latest-light-jre
	docker rmi $REGISTRY/platform:5-latest-light-centos-17-jre

	docker rmi $REGISTRY/platform:5-latest-light-jvmless > /dev/null 2>&1
	docker tag $REGISTRY/platform:5-latest-light-centos-jvmless $REGISTRY/platform:5-latest-light-jvmless
	docker rmi $REGISTRY/platform:5-latest-light-centos-jvmless

	docker rmi $REGISTRY/platform:5-light > /dev/null 2>&1
	docker tag $REGISTRY/platform:5-latest-light $REGISTRY/platform:5-light
	
	if [ $PUSH -eq 1 ]
	then
		./push-to-registries.sh --delete platform \
			5-latest-light \
			5-latest-light-alpine \
			5-latest-light-jvmless \
			5-latest-light-jre \
			5-light
	fi

	# First additional tag only
	for TAG in $1
	do
		docker rmi $REGISTRY/platform:$TAG-light > /dev/null 2>&1
		docker tag $REGISTRY/platform:5-latest-light $REGISTRY/platform:$TAG-light

		if [ $PUSH -eq 1 ]
		then
			./push-to-registries.sh --delete platform $TAG-light
		fi
	done
	docker rmi $REGISTRY/platform:5-latest-light
fi

# -------------------------------------------------------------------------------------------
# Previous versions
# -------------------------------------------------------------------------------------------

if [ "$TARGET" = "5.0" -o "$TARGET" = "5.1" -o "$TARGET" = "5.2" ]
then
	./build-platform.sh --delete $TARGET || exit_with $? "Unable to build platform version $TARGET"
	./build-platform.sh --delete $TARGET-light || exit_with $? "Unable to build platform version $TARGET-light"

	docker rmi $REGISTRY/platform:$TARGET > /dev/null 2>&1
	docker tag $REGISTRY/platform:$TARGET-centos-17 $REGISTRY/platform:$TARGET
	docker rmi $REGISTRY/platform:$TARGET-centos-17

	docker rmi $REGISTRY/platform:$TARGET-light > /dev/null 2>&1
	docker tag $REGISTRY/platform:$TARGET-light-centos-17 $REGISTRY/platform:$TARGET-light
	docker rmi $REGISTRY/platform:$TARGET-light-centos-17

	if [ $PUSH -eq 1 ]
	then
		./push-to-registries.sh platform $TARGET
		./push-to-registries.sh --delete platform $TARGET-light
	fi

	# All additional tags
	for TAG in $@
	do
		docker rmi $REGISTRY/platform:$TAG > /dev/null 2>&1
		docker tag $REGISTRY/platform:$TARGET $REGISTRY/platform:$TAG

		if [ $PUSH -eq 1 ]
		then
			./push-to-registries.sh --delete platform $TAG
		fi
	done
fi

exit_with
