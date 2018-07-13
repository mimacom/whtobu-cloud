#!/bin/bash
set -e

CURRENT_PATH=`dirname $0`

rm -rf ${CURRENT_PATH}/dist/
rm -f ${CURRENT_PATH}/amazon-product-api.zip
mkdir -p ${CURRENT_PATH}/dist/
cp -r ${CURRENT_PATH}/src/* ${CURRENT_PATH}/dist/

pushd ${CURRENT_PATH}/dist
    zip -vr ../amazon-product-api.zip index.js node_modules
popd