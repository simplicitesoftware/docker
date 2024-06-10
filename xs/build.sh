#!/bin/bash

SIMPLICITE_BASE_IMAGE="registry.simplicite.io/platform"

for SIMPLICITE_BASE_TAG in 6-latest-light #5-latest-light #5-beta 5-beta-light 
do
    # Base image from which the dockerfile copies the webapp
    SIMPLICITE_BASE="$SIMPLICITE_BASE_IMAGE:$SIMPLICITE_BASE_TAG"
    
    # Name of the built image
    TARGET_TAG="$SIMPLICITE_BASE_TAG-xs"
    TARGET_IMAGE="$SIMPLICITE_BASE_IMAGE:$TARGET_TAG"

    # Run build (see `./Dockerfile``)
    docker pull $SIMPLICITE_BASE
    docker build \
        --build-arg SIMPLICITE_BASE=$SIMPLICITE_BASE \
        -t $TARGET_IMAGE .
    
    SIZE_ORG="$(docker images $SIMPLICITE_BASE -q --format '{{.Size}}' )"
    SIZE_TRG="$(docker images $TARGET_IMAGE -q --format '{{.Size}}' )"
    echo "XS image $TARGET_TAG : $SIZE_ORG -> $SIZE_TRG"

    # Push
    # docker image tag $TARGET_IMAGE
    # docker push $TARGET_IMAGE
    # docker rmi $TARGET_IMAGE
done

docker image prune -f
# docker run -it --rm --name sim_arm -p 8080:8080 $TARGET_IMAGE