#!/usr/bin/env bash

set -e
echo "Running version update"
VERSION_FILE=../version.txt

VERSION=`head -n 1 ${VERSION_FILE}`

if [[ -z "$VERSION" ]]; then

    echo "Error: Unable to determine version number"
    exit 1

fi

NEW_VERSION=$(echo ${VERSION} | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{$NF=sprintf("%0d",  ($NF+1)); print}')

echo "${NEW_VERSION}" > ${VERSION_FILE}

cat ${VERSION_FILE}

BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

set -x

git add ${VERSION_FILE}

git commit -m "Built ${VERSION} and set next version to ${NEW_VERSION}"

git pull origin ${BRANCH_NAME}

git push origin ${BRANCH_NAME}