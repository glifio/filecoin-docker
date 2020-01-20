#!/bin/bash

ORG="openworklabs"
IMAGE="lotus"

VERSION=`cat LOTUS_VERSION`
echo "version: $VERSION"

# Tag the current revision in git
git tag -a "$VERSION" -m "version $VERSION"
git push
git push --tags

docker tag $ORG/$IMAGE\:latest $ORG/$IMAGE:$VERSION

# push it
docker push $ORG/$IMAGE\:latest
docker push $ORG/$IMAGE:$VERSION