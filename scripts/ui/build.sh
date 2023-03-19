#!/bin/bash

cd $(dirname $(realpath $0))/..

# Build the Gibber UI
cd npm run build 

# Get the version of the Gibber UI
VERSION=$(jq -r '.version' package.json)

# Create the image name / tag
IMAGE_NAME="austinagi/gibber-ui:$VERSION"

# Build and push the Gibber UI docker container
docker build -t $IMAGE_NAME . && \
    docker push $IMAGE_NAME