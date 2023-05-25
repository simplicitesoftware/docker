#!/bin/bash

exit_with () {
	[ "$2" != "" ] && echo -e $2 >&2
	exit ${1:-0}
}

[ "$1" = "--help" ] && exit_with 1 "\nUsage: \e[1m$(basename $0)\e[0m\n" 

REGISTRY=registry.simplicite.io

VERSIONS="3.0 3.1 3.2"
for VERSION in $VERSIONS
do
	./build-platform.sh --delete $VERSION || exit_with $? "Unable to build platform version $VERSION"
	docker rmi $REGISTRY/platform:$VERSION
	docker tag $REGISTRY/platform:$VERSION-openjdk-1.8.0 $REGISTRY/platform:$VERSION
	docker rmi $REGISTRY/platform:$VERSION-openjdk-1.8.0
done

./push-to-registries.sh --delete platform $VERSIONS

exit_with
