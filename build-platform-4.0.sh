#!/bin/bash

./build-platform.sh --delete 4.0-latest
docker rmi simplicite/platform:4.0
docker tag simplicite/platform:4.0-latest simplicite/platform:4.0

./build-platform.sh --delete 4.0-latest-light
docker rmi simplicite/platform:4.0-light
docker tag simplicite/platform:4.0-latest-light simplicite/platform:4.0-light

exit 0
