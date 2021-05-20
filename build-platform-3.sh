#!/bin/bash

VERSIONS="3.0 3.1 3.2"
for VERSION in $VERSIONS
do
	./build-platform.sh --delete $VERSION
	docker rmi simplicite/platform:$VERSION
	docker tag simplicite/platform:$VERSION-openjdk-1.8.0 simplicite/platform:$VERSION
	docker rmi simplicite/platform:$VERSION-openjdk-1.8.0
done

./push-to-registries.sh platform $VERSIONS

exit 0
