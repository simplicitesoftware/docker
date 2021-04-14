#!/bin/bash

if [ "$1" = "" -o "$1" = "--help" ]
then
	echo "Usage: `basename $0` <all|alpha|beta|latest>" >&2 
	exit -1
fi

if [ "$1" = "alpha" -o "$1" = "all" ]
then
	./build-platform.sh --delete 5-alpha
	./build-platform.sh --delete 5-alpha-light
	./build-platform.sh --delete 5-alpha-test
fi

if [ "$1" = "beta" -o "$1" = "all" ]
then
	./build-platform.sh --delete 5-beta
	./build-platform.sh --delete 5-beta-light
fi

if [ "$1" = "latest" -o "$1" = "all" ]
then
	./build-platform.sh --delete 5-latest
	docker rmi simplicite/platform:5
	docker tag simplicite/platform:5-latest simplicite/platform:5
	docker rmi simplicite/platform:latest
	docker tag simplicite/platform:5-latest simplicite/platform:latest

	./build-platform.sh --delete 5-latest-light
	docker rmi simplicite/platform:5-light
	docker tag simplicite/platform:5-latest-light simplicite/platform:5-light
	docker rmi simplicite/platform:latest-light
	docker tag simplicite/platform:5-latest-light simplicite/platform:latest-light
fi

exit 0
