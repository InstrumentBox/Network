#!/bin/sh

#
#  DOCBUILD.sh
#
#  Copyright © 2022 Aleksei Zaikin.
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.
#

if [ -d ".docbuild" ]; then
    rm -rf .docbuild
fi

PACKAGE_NAME="Network"
SCHEME_NAME="Network-Package"

xcodebuild docbuild \
-scheme $SCHEME_NAME \
-derivedDataPath .docbuild \
-destination 'platform=iOS Simulator,name=iPhone 14 Pro'

DOC_PATH=$(find .docbuild -type d -name "$PACKAGE_NAME.doccarchive")

echo "Processing documentation archive to host on GitHub Pages..."

if [ -d $DOC_PATH ]; then
   $(xcrun --find docc) process-archive \
   transform-for-static-hosting $DOC_PATH \
   --output-path docs \
   --hosting-base-path $PACKAGE_NAME
   echo "$(tput setaf 2)** PROCESSING DOCUMENTATION SUCCEEDED **\n"
else
   echo "$(tput setaf 1)** CAN'T FIND ${PACKAGE_NAME^^} DOCUMENTATION ARCHIVE **\n"
fi
