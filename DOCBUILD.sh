#!/bin/sh

if [ -d ".docbuild" ]; then
    rm -rf .docbuild
fi

xcodebuild docbuild \
-scheme Network \
-derivedDataPath .docbuild \
-destination 'platform=iOS Simulator,name=iPhone 13 mini'

DOC_PATH=$(find .docbuild -type d -name "*.doccarchive")

$(xcrun --find docc) process-archive \
transform-for-static-hosting $DOC_PATH \
--output-path docs \
--hosting-base-path Network
