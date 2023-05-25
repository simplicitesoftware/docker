#!/bin/bash

REGISTRY=registry.simplicite.io

for SIMPLICITE_BASE_TAG in 5-beta
do
    # Base image from which the dockerfile copies the webapp
    SIMPLICITE_BASE="$REGISTRY/platform:$SIMPLICITE_BASE_TAG"
    
    # Name of the built image
    TARGET_TAG="$SIMPLICITE_BASE_TAG-xs-test-bdx"
    TARGET_IMAGE="$REGISTRY/platform:$TARGET_TAG"

    # Run build (see ./Dockerfile)
    docker buildx build --pull \
        --platform linux/arm/v7,linux/arm64,linux/amd64 \
        --build-arg SIMPLICITE_BASE=$SIMPLICITE_BASE \
        -t $TARGET_IMAGE .

    # Push
    # docker push $TARGET_IMAGE
done

docker image prune -f
# ./delete-from-private-registry.sh platform 5-beta-xs-test-bdx
# docker run -it --rm --name sim_arm -p 8080:8080 $TARGET_IMAGE 
