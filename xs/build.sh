#!/bin/bash

for SIMPLICITE_BASE_TAG in 5-beta 5-beta-light 5-latest 5-latest-light
do
    # Base image from which the dockerfile copies the webapp
    SIMPLICITE_BASE="simplicite/platform:$SIMPLICITE_BASE_TAG"
    
    # Name of the built image
    TARGET_TAG="$SIMPLICITE_BASE_TAG-xs"
    TARGET_IMAGE="simplicite/platform:$TARGET_TAG"

    # Run build (see ./Dockerfile)
    docker build --pull \
        --build-arg SIMPLICITE_BASE=$SIMPLICITE_BASE \
        -t $TARGET_IMAGE .

    # Push
    # PUSH_TAG="registry.simplicite.io/platform:$TARGET_TAG"
    # docker image tag $TARGET_IMAGE $PUSH_TAG
    # docker push $PUSH_TAG
    # docker rmi $PUSH_TAG
done

docker image prune -f
# docker run -it --rm --name sim_arm -p 8080:8080 $TARGET_IMAGE 