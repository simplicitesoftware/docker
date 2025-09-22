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

#[ "$1" = "" -o "$1" = "--help" ] && exit_with 1 "\nUsage: \e[1m$(basename $0)\e[0m <alpha|beta|preview|latest> [<additional tags, e.g. 7.x 7.x.y\>]\n" 
[ "$1" = "" -o "$1" = "--help" ] && exit_with 1 "\nUsage: \e[1m$(basename $0)\e[0m <alpha>\n" 

TARGET=$1
shift

# -------------------------------------------------------------------------------------------
# Next versions
# -------------------------------------------------------------------------------------------

#if [ "$TARGET" = "alpha" -o "$TARGET" = "beta" ]
if [ "$TARGET" = "alpha" ]
then
	./build-platform.sh --delete 7-$TARGET || exit_with $? "Unable to build platform version 7-$TARGET"

	docker rmi $REGISTRY/platform:7-$TARGET > /dev/null 2>&1
	docker tag $REGISTRY/platform:7-$TARGET-almalinux10-25-tomcat11 $REGISTRY/platform:7-$TARGET
	docker rmi $REGISTRY/platform:7-$TARGET-almalinux10-25-tomcat11

	docker rmi $REGISTRY/platform:7-$TARGET-jre > /dev/null 2>&1
	docker tag $REGISTRY/platform:7-$TARGET-almalinux10-25-jre-tomcat11 $REGISTRY/platform:7-$TARGET-jre
	docker rmi $REGISTRY/platform:7-$TARGET-almalinux10-25-jre-tomcat11

	[ $PUSH -eq 1 ] && ./push-to-registries.sh platform \
		7-$TARGET \
		7-$TARGET-jre

#	./build-platform.sh --delete 7-$TARGET-light || exit_with $? "Unable to build platform version 7-$TARGET-light"
#
#	docker rmi $REGISTRY/platform:7-$TARGET-light > /dev/null 2>&1
#	docker tag $REGISTRY/platform:7-$TARGET-light-almalinux10-25-tomcat11 $REGISTRY/platform:7-$TARGET-light
#	docker rmi $REGISTRY/platform:7-$TARGET-light-almalinux10-25-tomcat11
#
#	docker rmi $REGISTRY/platform:7-$TARGET-light-jre > /dev/null 2>&1
#	docker tag $REGISTRY/platform:7-$TARGET-light-almalinux10-25-jre-tomcat11 $REGISTRY/platform:7-$TARGET-light-jre
#	docker rmi $REGISTRY/platform:7-$TARGET-light-almalinux10-25-jre-tomcat11
#
#	[ $PUSH -eq 1 ] && ./push-to-registries.sh --delete platform \
#		7-$TARGET-light \
#		7-$TARGET-light-jre

	exit_with
fi

# -------------------------------------------------------------------------------------------
# Next version with development tools
# -------------------------------------------------------------------------------------------

##if [ "$TARGET" = "alpha-devel" -o "$TARGET" = "beta-devel" ]
#if [ "$TARGET" = "alpha-devel" ]
#then
#	./build-platform.sh --delete 7-$TARGET || exit_with $? "Unable to build platform version 7-$TARGET"
#
#	exit_with
#fi

# -------------------------------------------------------------------------------------------
# Current version preview
# -------------------------------------------------------------------------------------------

#if [ "$TARGET" = "preview" ]
#then
#	./build-platform.sh --delete 7-$TARGET almalinux10-25-tomcat11 || exit_with $? "Unable to build platform version 7-$TARGET"
#
#	docker rmi $REGISTRY/platform:7-$TARGET > /dev/null 2>&1
#	docker tag $REGISTRY/platform:7-$TARGET-almalinux10-25-tomcat11 $REGISTRY/platform:7-$TARGET
#	docker rmi $REGISTRY/platform:7-$TARGET-almalinux10-25-tomcat11
#
#	[ $PUSH -eq 1 ] && ./push-to-registries.sh platform 7-$TARGET
#
#	exit_with
#fi

# -------------------------------------------------------------------------------------------
# Current version
# -------------------------------------------------------------------------------------------

#if [ "$TARGET" = "latest" ]
#then
#	./build-platform.sh --delete 7-$TARGET || exit_with $? "Unable to build platform version 7-$TARGET"
#
#	docker rmi $REGISTRY/platform:7-$TARGET > /dev/null 2>&1
#	docker tag $REGISTRY/platform:7-$TARGET-almalinux10-25-tomcat11 $REGISTRY/platform:7-$TARGET
#	docker rmi $REGISTRY/platform:7-$TARGET-almalinux10-25-tomcat11
#
#	docker rmi $REGISTRY/platform:7-$TARGET-jre > /dev/null 2>&1
#	docker tag $REGISTRY/platform:7-$TARGET-almalinux10-25-jre-tomcat11 $REGISTRY/platform:7-$TARGET-jre
#	docker rmi $REGISTRY/platform:7-$TARGET-almalinux10-25-jre-tomcat11
#
#	docker rmi $REGISTRY/platform:7-$TARGET-jvmless > /dev/null 2>&1
#	docker tag $REGISTRY/platform:7-$TARGET-almalinux10-jvmless $REGISTRY/platform:7-$TARGET-jvmless
#	docker rmi $REGISTRY/platform:7-$TARGET-almalinux10-jvmless
#
#	docker rmi $REGISTRY/platform:7 $REGISTRY/platform:$TARGET > /dev/null 2>&1
#	docker tag $REGISTRY/platform:7-$TARGET $REGISTRY/platform:7
#	docker tag $REGISTRY/platform:7-$TARGET $REGISTRY/platform:$TARGET
#
#	if [ $PUSH -eq 1 ]
#	then
#		./push-to-registries.sh --delete platform \
#			7-$TARGET-alpine \
#			7-$TARGET-alpine-jre \
#			7-$TARGET-jre \
#			7-$TARGET-jvmless \
#			7 \
#			$TARGET
#		./push-to-registries.sh platform 7-$TARGET
#	fi
#
#	# All additional tags
#	for TAG in $@
#	do
#		docker rmi $REGISTRY/platform:$TAG > /dev/null 2>&1
#		docker tag $REGISTRY/platform:7-$TARGET $REGISTRY/platform:$TAG
#
#		if [ $PUSH -eq 1 ]
#		then
#			./push-to-registries.sh --delete platform $TAG
#		fi
#	done
#
#	./build-platform.sh --delete 7-$TARGET-light || exit_with $? "Unable to build platform version 7-$TARGET-light"
#
#	docker rmi $REGISTRY/platform:7-$TARGET-light > /dev/null 2>&1
#	docker tag $REGISTRY/platform:7-$TARGET-light-almalinux10-25-tomcat11 $REGISTRY/platform:7-$TARGET-light
#	docker rmi $REGISTRY/platform:7-$TARGET-light-almalinux10-25-tomcat11
#
#	docker rmi $REGISTRY/platform:7-$TARGET-light-jre > /dev/null 2>&1
#	docker tag $REGISTRY/platform:7-$TARGET-light-almalinux10-25-jre-tomcat11 $REGISTRY/platform:7-$TARGET-light-jre
#	docker rmi $REGISTRY/platform:7-$TARGET-light-almalinux10-25-jre-tomcat11
#
#	docker rmi $REGISTRY/platform:7-$TARGET-light-jvmless > /dev/null 2>&1
#	docker tag $REGISTRY/platform:7-$TARGET-light-almalinux10-jvmless $REGISTRY/platform:7-$TARGET-light-jvmless
#	docker rmi $REGISTRY/platform:7-$TARGET-light-almalinux10-jvmless
#
#	docker rmi $REGISTRY/platform:7-light $REGISTRY/platform:$TARGET-light > /dev/null 2>&1
#	docker tag $REGISTRY/platform:7-$TARGET-light $REGISTRY/platform:7-light
#	docker tag $REGISTRY/platform:7-$TARGET-light $REGISTRY/platform:$TARGET-light
#
#	if [ $PUSH -eq 1 ]
#	then
#		./push-to-registries.sh --delete platform \
#			7-$TARGET-light-alpine \
#			7-$TARGET-light-alpine-jre \
#			7-$TARGET-light-jre \
#			7-$TARGET-light-jvmless \
#			7-light \
#			$TARGET-light
#		./push-to-registries.sh platform 7-$TARGET-light
#	fi
#
#	# First additional tag only
#	for TAG in $1
#	do
#		docker rmi $REGISTRY/platform:$TAG-light > /dev/null 2>&1
#		docker tag $REGISTRY/platform:7-$TARGET-light $REGISTRY/platform:$TAG-light
#
#		if [ $PUSH -eq 1 ]
#		then
#			./push-to-registries.sh --delete platform $TAG-light
#		fi
#	done
#	docker rmi $REGISTRY/platform:7-$TARGET-light
#
#	exit_with
#fi

# -------------------------------------------------------------------------------------------
# Current version whith development tools
# -------------------------------------------------------------------------------------------

#if [ "$TARGET" = "devel" ]
#then
#	./build-platform.sh --delete 7-$TARGET || exit_with $? "Unable to build platform version 7-$TARGET"
#
#	exit_with
#fi

exit_with 1 "Unknown target $TARGET"