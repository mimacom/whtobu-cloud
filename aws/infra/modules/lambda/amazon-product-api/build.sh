#!/bin/bash
set -e

CURRENT_PATH=`dirname $0`

rm -f amazon-product-api.zip
mkdir ${CURRENT_PATH}/dist/
cp ${CURRENT_PATH}/src/* ${CURRENT_PATH}/dist/

pushd ${CURRENT_PATH}/dist
    zip -vr ../amazon-product-api.zip index.js
popd