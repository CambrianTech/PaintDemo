#!/bin/sh -e

# for more info, go here:
#https://github.com/Carthage/Carthage/blob/master/Documentation/StaticFrameworks.md

carthage update --platform iOS --no-use-binaries --no-build

#static frameworks go here:
echo "Building static frameworks"

Carthage/carthage-build-static.sh --platform ios --cache-builds
