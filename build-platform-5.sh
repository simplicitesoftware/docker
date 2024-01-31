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

[ "$1" = "" -o "$1" = "--help" ] && exit_with 1 "\nUsage: \e[1m$(basename $0)\e[0m <latest|preview|5.x> [<additional tags, e.g. \"5.x 5.x.y\">]\n" 

# Current version

if [ "$1" = "latest" ]
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

	# Additional tags
	for TAG in ${@:2}
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
			5-latest-light-alpine \
			5-latest-light \
			5-latest-light-jvmless \
			5-latest-light-jre \
			5-light
	fi

	# Additional tags
	for TAG in ${@:2}
	do
		docker rmi $REGISTRY/platform:$TAG-light > /dev/null 2>&1
		docker tag $REGISTRY/platform:5-latest-light $REGISTRY/platform:$TAG-light

		if [ $PUSH -eq 1 ]
		then
			./push-to-registries.sh --delete platform $TAG-light
		fi
	done
fi

# Preview version

if [ "$1" = "preview" ]
then
	./build-platform.sh --delete 5-preview || exit_with $? "Unable to build platform version 5-preview"

	docker rmi $REGISTRY/platform:5-preview > /dev/null 2>&1
	docker tag $REGISTRY/platform:5-preview-centos-17 $REGISTRY/platform:5-preview
	docker rmi $REGISTRY/platform:5-preview-centos-17

	#[ $PUSH -eq 1 ] && ./push-to-registries.sh platform 5-preview

	#./build-platform.sh --delete 5-preview-light || exit_with $? "Unable to build platform version 5-preview-light"

	#docker rmi $REGISTRY/platform:5-preview-light > /dev/null 2>&1
	#docker tag $REGISTRY/platform:5-preview-light-centos-17 $REGISTRY/platform:5-preview-light
	#docker rmi $REGISTRY/platform:5-preview-light-centos-17

	#[ $PUSH -eq 1 ] && ./push-to-registries.sh --delete platform 5-preview-light
fi

# Previous versions

if [ "$1" = "5.0" -o "$1" = "5.1" -o "$1" = "5.2" ]
then
	./build-platform.sh --delete $1 || exit_with $? "Unable to build platform version $1"
	./build-platform.sh --delete $1-light || exit_with $? "Unable to build platform version $1-light"

	docker rmi $REGISTRY/platform:$1 > /dev/null 2>&1
	docker tag $REGISTRY/platform:$1-centos-17 $REGISTRY/platform:$1
	docker rmi $REGISTRY/platform:$1-centos-17

	docker rmi $REGISTRY/platform:$1-light > /dev/null 2>&1
	docker tag $REGISTRY/platform:$1-light-centos-17 $REGISTRY/platform:$1-light
	docker rmi $REGISTRY/platform:$1-light-centos-17

	if [ $PUSH -eq 1 ]
	then
		./push-to-registries.sh platform $1
		./push-to-registries.sh --delete platform $1-light
	fi

	# Additional tags
	for TAG in ${@:2}
	do
		docker rmi $REGISTRY/platform:$TAG > /dev/null 2>&1
		docker tag $REGISTRY/platform:$1 $REGISTRY/platform:$TAG

		if [ $PUSH -eq 1 ]
		then
			./push-to-registries.sh --delete platform $TAG
		fi
	done
fi

exit_with
