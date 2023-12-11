#!/bin/bash

set -ex

# SET THE FOLLOWING VARIABLES
# docker hub username
USERNAME=fredericklab
# image name
IMAGE=basecontainer_plus

# ensure we're up to date
git pull

# bump version
python revversion.py
version=`cat VERSION | sed 's/+/ /g' | sed 's/v//g' | awk '{print $1}'`
echo "version: $version"

# run build
docker buildx build . \
    --platform linux/amd64 \
    -t $IMAGE \
    --tag $USERNAME/$IMAGE:latest \
    --tag $USERNAME/$IMAGE:$version \
    --tag $USERNAME/$IMAGE:latest-release \
    --build-arg VERSION=$version \
    --build-arg BUILD_DATE=`date +"%Y%m%dT%H%M%S"` \
    --build-arg VCS_REF=`git rev-parse HEAD`

docker buildx build . \
    --platform linux/arm64 \
    -t $IMAGE \
    --tag $USERNAME/$IMAGE:latest \
    --tag $USERNAME/$IMAGE:$version \
    --tag $USERNAME/$IMAGE:latest-release \
    --build-arg VERSION=$version \
    --build-arg BUILD_DATE=`date +"%Y%m%dT%H%M%S"` \
    --build-arg VCS_REF=`git rev-parse HEAD`

docker push fredericklab/basecontainer_plus:latest
docker push fredericklab/basecontainer_plus:$version
docker push fredericklab/basecontainer_plus:latest-release
