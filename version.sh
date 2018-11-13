#!/bin/sh
#get version from tag, if no tags set to 1.0
VERSION=`git describe --abbrev=0 --tags`

if [ -z "$VERSION" ]; then
 VERSION='1.0'
fi

echo $VERSION
