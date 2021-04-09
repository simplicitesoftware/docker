#!/bin/bash

IMGS=${1:-server platform theia}

for IMG in $IMGS
do
        echo ""
        echo "------------------------------------"
        echo "$IMG"
        echo "------------------------------------"

        for TAG in `docker images | grep "^simplicite.$IMG" | awk '{print ":"$2}'`
        do
                echo ""
                echo "Pushing image $IMG$TAG to DockerHub registry"
                echo sudo docker push simplicite/$IMG$TAG
                echo "Done"
                echo "Pushing image $IMG$TAG to local registry"
                echo sudo docker tag simplicite/$IMG$TAG localhost:5000/$IMG$TAG;
                echo sudo docker push localhost:5000/$IMG$TAG
                echo sudo docker rmi localhost:5000/$IMG$TAG
                echo "Done"
        done
done
echo ""
exit 0

