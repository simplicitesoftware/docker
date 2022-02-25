#!/bin/bash
docker kill sim_arm
docker build -f Dockerfile-arm -t simplicite/platform:arm .
docker image prune -f
docker run -it --rm --name sim_arm -p 8080:8080 simplicite/platform:arm 