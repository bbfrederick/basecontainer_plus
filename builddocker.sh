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
version=`cat VERSION | sed 's/+/ /g' | sed 's/v//g' | awk '{print "v"$1}'`
echo "version: $version"

version=latest

# run build
docker buildx build . \
    --platform linux/arm64,linux/amd64 \
    --tag $USERNAME/$IMAGE:latest \
    --tag $USERNAME/$IMAGE:$version \
    --build-arg VERSION=$version \
    --build-arg BUILD_DATE=`date +"%Y%m%dT%H%M%S"` \
    --build-arg VCS_REF=`git rev-parse HEAD`

#docker buildx build . \
#    --platform linux/amd64 \
#    -t $IMAGE \
#    --tag $USERNAME/$IMAGE:latest \
#    --tag $USERNAME/$IMAGE:$version \
#    --tag $USERNAME/$IMAGE:latest-release \
#    --build-arg VERSION=$version \
#    --build-arg BUILD_DATE=`date +"%Y%m%dT%H%M%S"` \
#    --build-arg VCS_REF=`git rev-parse HEAD`
#    2>&1 | tee build.log
#
#docker push fredericklab/basecontainer_plus:latest
#docker push fredericklab/basecontainer_plus:$version
#docker push fredericklab/basecontainer_plus:latest-release
