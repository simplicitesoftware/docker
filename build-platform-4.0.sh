#!/bin/bash

./build-platform.sh 4.0-latest
docker tag simplicite/platform:4.0-latest simplicite/platform:4.0

./build-platform.sh 4.0-latest-light
docker tag simplicite/platform:4.0-latest-light simplicite/platform:4.0-light

exit 0
