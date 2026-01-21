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
	echo "Building platform images for $TARGET"
	./build-platform.sh --delete 6-$TARGET || exit_with $? "Unable to build platform version 6-$TARGET"
	echo "Done"

	echo "Tagging 6-$TARGET"
	docker rmi $REGISTRY/platform:6-$TARGET > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET-almalinux9-21 $REGISTRY/platform:6-$TARGET
	docker rmi $REGISTRY/platform:6-$TARGET-almalinux9-21
	echo "Done"

	echo "Tagging 6-$TARGET-jre"
	docker rmi $REGISTRY/platform:6-$TARGET-jre > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET-almalinux9-21-jre $REGISTRY/platform:6-$TARGET-jre
	docker rmi $REGISTRY/platform:6-$TARGET-almalinux9-21-jre
	echo "Done"

	if [ $PUSH -eq 1 ]
	then
		echo "Pushing tags 6-$TARGET and 6-$TARGET-jre"
		./push-to-registries.sh platform 6-$TARGET $TARGET-jre
		echo "Done"
	fi

	exit_with
fi

# -------------------------------------------------------------------------------------------
# Current version => tags: 6-latest / 6-latest-light / 6-latest-jre / 6-latest-light-jre / 6.3 / 6.3-light / 6.3-jre / 6.3-light-jre / 6.3.x / 6.3.x-light"
# -------------------------------------------------------------------------------------------

if [ "$TARGET" = "latest" ]
then
	echo "Building platform images for $TARGET and $TARGET-light"
	./build-platform.sh --delete 6-$TARGET || exit_with $? "Unable to build platform version 6-$TARGET"
	./build-platform.sh --delete 6-$TARGET-light || exit_with $? "Unable to build platform version 6-$TARGET-light"
	echo "Done"

	echo "Tagging 6-$TARGET"
	docker rmi $REGISTRY/platform:6-$TARGET > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET-almalinux9-21 $REGISTRY/platform:6-$TARGET
	docker rmi $REGISTRY/platform:6-$TARGET-almalinux9-21

	echo "Tagging 6-$TARGET-jre"
	docker rmi $REGISTRY/platform:6-$TARGET-jre > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET-almalinux9-21-jre $REGISTRY/platform:6-$TARGET-jre
	docker rmi $REGISTRY/platform:6-$TARGET-almalinux9-21-jre

	echo "Tagging 6-$TARGET-jvmless"
	docker rmi $REGISTRY/platform:6-$TARGET-jvmless > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET-almalinux9-jvmless $REGISTRY/platform:6-$TARGET-jvmless
	docker rmi $REGISTRY/platform:6-$TARGET-almalinux9-jvmless
	echo "Done"

	echo "Tagging 6"
	docker rmi $REGISTRY/platform:6 $REGISTRY/platform:6 > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET $REGISTRY/platform:6
	echo "Done"

	echo "Tagging $TARGET"
	docker rmi $REGISTRY/platform:6 $REGISTRY/platform:$TARGET > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET $REGISTRY/platform:$TARGET
	echo "Done"

	if [ $PUSH -eq 1 ]
	then
		echo "Pushing tags 6-$TARGET[-<alpine|alpine-jre|jre|jvmless>], 6 and $TARGET"
		./push-to-registries.sh --delete platform \
			6-$TARGET-alpine \
			6-$TARGET-alpine-jre \
			6-$TARGET-jre \
			6-$TARGET-jvmless \
			6 \
			$TARGET
		./push-to-registries.sh platform 6-$TARGET
		echo "Done"
	fi

	for TAG in 6.3 $1
	do
		echo "Tagging $TAG"
		docker rmi $REGISTRY/platform:$TAG > /dev/null 2>&1
		docker tag $REGISTRY/platform:6-$TARGET $REGISTRY/platform:$TAG
		echo "Done"

		if [ $TAG = "6.3" ]
		then
			echo "Tagging $TAG-jre"
			docker rmi $REGISTRY/platform:$TAG-jre > /dev/null 2>&1
			docker tag $REGISTRY/platform:6-$TARGET-jre $REGISTRY/platform:$TAG-jre
			echo "Done"
		fi

		if [ $PUSH -eq 1 ]
		then
			echo "Pushing tag $TAG"
			./push-to-registries.sh --delete platform $TAG
			echo "Done"

			if [ $TAG = "6.3" ]
			then
				echo "Pushing tag $TAG-jre"
				./push-to-registries.sh --delete platform $TAG-jre
				echo "Done"
			fi
		fi
	done

	echo "Tagging 6-$TARGET-light"
	docker rmi $REGISTRY/platform:6-$TARGET-light > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET-light-almalinux9-21 $REGISTRY/platform:6-$TARGET-light
	docker rmi $REGISTRY/platform:6-$TARGET-light-almalinux9-21
	echo "Done"

	echo "Tagging 6-$TARGET-light-jre"
	docker rmi $REGISTRY/platform:6-$TARGET-light-jre > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET-light-almalinux9-21-jre $REGISTRY/platform:6-$TARGET-light-jre
	docker rmi $REGISTRY/platform:6-$TARGET-light-almalinux9-21-jre
	echo "Done"

	echo "Tagging 6-$TARGET-jvmless"
	docker rmi $REGISTRY/platform:6-$TARGET-light-jvmless > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET-light-almalinux9-jvmless $REGISTRY/platform:6-$TARGET-light-jvmless
	docker rmi $REGISTRY/platform:6-$TARGET-light-almalinux9-jvmless
	echo "Done"

	echo "Tagging 6-light"
	docker rmi $REGISTRY/platform:6-light $REGISTRY/platform:6-$TARGET-light > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET-light $REGISTRY/platform:6-light
	echo "Done"

	echo "Tagging $TARGET-light"
	docker rmi $REGISTRY/platform:6-light $REGISTRY/platform:$TARGET-light > /dev/null 2>&1
	docker tag $REGISTRY/platform:6-$TARGET-light $REGISTRY/platform:$TARGET-light
	echo "Done"

	if [ $PUSH -eq 1 ]
	then
		echo "Pushing tags 6-$TARGET-light[-<alpine|alpine-jre|jre|jvmless>], 6-light and $TARGET-light"
		./push-to-registries.sh --delete platform \
			6-$TARGET-light-alpine \
			6-$TARGET-light-alpine-jre \
			6-$TARGET-light-jre \
			6-$TARGET-light-jvmless \
			6-light \
			$TARGET-light
		./push-to-registries.sh platform 6-$TARGET-light
		echo "Done"
	fi

	for TAG in 6.3 $1
	do
		echo "Tagging $TAG-light"
		docker rmi $REGISTRY/platform:$TAG-light > /dev/null 2>&1
		docker tag $REGISTRY/platform:6-$TARGET-light $REGISTRY/platform:$TAG-light
		echo "Done"

		if [ $TAG = "6.3" ]
		then
			echo "Tagging $TAG-light-jre"
			docker rmi $REGISTRY/platform:$TAG-light-jre > /dev/null 2>&1
			docker tag $REGISTRY/platform:6-$TARGET-light-jre $REGISTRY/platform:$TAG-light-jre
			echo "Done"
		fi

		if [ $PUSH -eq 1 ]
		then
			echo "Pushing tag $TAG-light"
			./push-to-registries.sh --delete platform $TAG-light
			echo "Done"

			if [ $TAG = "6.3" ]
			then
				echo "Pushing tag $TAG-light-jre"
				./push-to-registries.sh --delete platform $TAG-light-jre
				echo "Done"
			fi
		fi
	done

	exit_with
fi

if [ "$TARGET" = "devel" ]
then
	echo "Building platform images for $TARGET"
	./build-platform.sh --delete 6-$TARGET || exit_with $? "Unable to build platform version 6-$TARGET"
	echo "Done"

	exit_with
fi

# -------------------------------------------------------------------------------------------
# Previous versions => tags: 6.x / 6.x-light / 6.x.y / 6.x.y-light (plus -jre tags for 6.2 only ZZZ temporary ZZZ)
# -------------------------------------------------------------------------------------------

if [ "$TARGET" = "6.0" -o "$TARGET" = "6.1" -o "$TARGET" = "6.2" ]
then
	echo "Building platform images for $TARGET and $TARGET-light"
	./build-platform.sh --delete $TARGET || exit_with $? "Unable to build platform version $TARGET"
	./build-platform.sh --delete $TARGET-light || exit_with $? "Unable to build platform version $TARGET-light"
	echo "Done"

	echo "Tagging $TARGET"
	docker rmi $REGISTRY/platform:$TARGET > /dev/null 2>&1
	docker tag $REGISTRY/platform:$TARGET-almalinux9-21 $REGISTRY/platform:$TARGET
	docker rmi $REGISTRY/platform:$TARGET-almalinux9-21
	echo "Done"

	echo "Tagging $TARGET-light"
	docker rmi $REGISTRY/platform:$TARGET-light > /dev/null 2>&1
	docker tag $REGISTRY/platform:$TARGET-light-almalinux9-21 $REGISTRY/platform:$TARGET-light
	docker rmi $REGISTRY/platform:$TARGET-light-almalinux9-21
	echo "Done"

	if [ $PUSH -eq 1 ]
	then
		echo "Pushing tags $TARGET and $TARGET-light"
		./push-to-registries.sh platform $TARGET
		./push-to-registries.sh --delete platform $TARGET-light
		echo "Done"
	fi

	# ZZZ temporary ZZZ
	if [ "$TARGET" = "6.2" ]
	then
		echo "Tagging $TARGET-jre"
		docker rmi $REGISTRY/platform:$TARGET-jre > /dev/null 2>&1
		docker tag $REGISTRY/platform:$TARGET-almalinux9-21 $REGISTRY/platform:$TARGET-jre
		docker rmi $REGISTRY/platform:$TARGET-almalinux9-21-jre
		echo "Done"
	
		echo "Tagging $TARGET-light-jre"
		docker rmi $REGISTRY/platform:$TARGET-light-jre > /dev/null 2>&1
		docker tag $REGISTRY/platform:$TARGET-light-almalinux9-21 $REGISTRY/platform:$TARGET-light-jre
		docker rmi $REGISTRY/platform:$TARGET-light-almalinux9-21-jre
		echo "Done"

		if [ $PUSH -eq 1 ]
		then
			echo "Pushing tags $TARGET-jre and $TARGET-light-jre"
			./push-to-registries.sh --delete platform $TARGET-jre platform $TARGET-light-jre
			echo "Done"
		fi
	fi

	for TAG in $1
	do
		echo "Tagging $TAG"
		docker rmi $REGISTRY/platform:$TAG > /dev/null 2>&1
		docker tag $REGISTRY/platform:$TARGET $REGISTRY/platform:$TAG
		echo "Done"

		echo "Tagging $TAG-light"
		docker rmi $REGISTRY/platform:$TAG-light > /dev/null 2>&1
		docker tag $REGISTRY/platform:$TARGET-light $REGISTRY/platform:$TAG-light
		echo "Done"

		if [ $PUSH -eq 1 ]
		then
			./push-to-registries.sh --delete platform $TAG $TAG-light
		fi
	done

	exit_with
fi

exit_with 1 "Unknown target $TARGET"
