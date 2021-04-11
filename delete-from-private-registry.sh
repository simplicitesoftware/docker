#!/bin/bash

ID=`curl -s --head -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -u $DOCKER_PRIVATE_REGISTRY_USERNAME:$DOCKER_PRIVATE_REGISTRY_PASSWORD $DOCKER_PRIVATE_REGISTRY_URL/v2/$1/manifests/$2 | grep '^Docker-Content-Digest:' | awk '{print $2}' | sed 's/\r$//'`
echo "Image ID = [$ID]"
[ "$ID" != "" ] && curl -X DELETE -u $DOCKER_PRIVATE_REGISTRY_USERNAME:$DOCKER_PRIVATE_REGISTRY_PASSWORD $DOCKER_PRIVATE_REGISTRY_URL/v2/$1/manifests/$ID

exit 0
