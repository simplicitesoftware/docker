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

#[ "$1" = "" -o "$1" = "--help" ] && exit_with 1 "\nUsage: \e[1m$(basename $0)\e[0m <alpha|beta|preview|latest|7.x> [<revision (for latest and 7.x)>]\n" 
[ "$1" = "" -o "$1" = "--help" ] && exit_with 1 "\nUsage: \e[1m$(basename $0)\e[0m <alpha>\n" 

TARGET=$1
REVISION=$2

CURRENT=7.0

# -------------------------------------------------------------------------------------------
# Alpha version
# -------------------------------------------------------------------------------------------

if [ "$TARGET" = "alpha" -o "$TARGET" = "$CURRENT" ]
then
	TARGET=alpha

	trace "Building platform images for $TARGET"
	./build-platform.sh --delete 7-$TARGET || exit_with $? "Unable to build platform version 7-$TARGET"
	trace "Done"

	trace "Tagging 7-$TARGET"
	docker rmi $REGISTRY/platform:7-$TARGET > /dev/null 2>&1
	docker tag $REGISTRY/platform:7-$TARGET-almalinux10-25-tomcat11 $REGISTRY/platform:7-$TARGET
	docker rmi $REGISTRY/platform:7-$TARGET-almalinux10-25-tomcat11
	trace "Done"

	trace "Tagging 7-$TARGET-jre"
	docker rmi $REGISTRY/platform:7-$TARGET-jre > /dev/null 2>&1
	docker tag $REGISTRY/platform:7-$TARGET-almalinux10-25-jre-tomcat11 $REGISTRY/platform:7-$TARGET-jre
	docker rmi $REGISTRY/platform:7-$TARGET-almalinux10-25-jre-tomcat11
	trace "Done"

	if [ $PUSH -eq 1 ]
	then
		trace "Pushing tags 7-$TARGET and 7-$TARGET-jre"
		./push-to-registries.sh platform \
		7-$TARGET \
		7-$TARGET-jre
		trace "Done"
	fi

#	trace "Building platform images for $TARGET-light"
#	./build-platform.sh --delete 7-$TARGET-light || exit_with $? "Unable to build platform version 7-$TARGET-light"
#	trace "Done"
#
#	trace "Tagging 7-$TARGET-light"
#	docker rmi $REGISTRY/platform:7-$TARGET-light > /dev/null 2>&1
#	docker tag $REGISTRY/platform:7-$TARGET-light-almalinux10-25-tomcat11 $REGISTRY/platform:7-$TARGET-light
#	docker rmi $REGISTRY/platform:7-$TARGET-light-almalinux10-25-tomcat11
#	trace "Done"
#
#	trace "Tagging 7-$TARGET-light-jre"
#	docker rmi $REGISTRY/platform:7-$TARGET-light-jre > /dev/null 2>&1
#	docker tag $REGISTRY/platform:7-$TARGET-light-almalinux10-25-jre-tomcat11 $REGISTRY/platform:7-$TARGET-light-jre
#	docker rmi $REGISTRY/platform:7-$TARGET-light-almalinux10-25-jre-tomcat11
#	trace "Done"
#
#	if [ $PUSH -eq 1 ]
#	then
#		trace "Pushing tags 7-$TARGET-light and 7-$TARGET-light-jre"
#		./push-to-registries.sh --delete platform \
#		7-$TARGET-light \
#		7-$TARGET-light-jre
#		trace "Done"
#	fi

	exit_with
fi

exit_with 1 "Unknown target $TARGET"