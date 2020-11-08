#!/usr/bin/env bash

usage() { echo "Usage: $0 -r <registry>" 1>&2; exit 1; }

set -e

declare registry=""
declare appVersion=""

# Initialize parameters specified from command line
while getopts ":r:" arg; do
	case "${arg}" in
		r)
			registry=${OPTARG}
			;;
		esac
done
shift $((OPTIND-1))

if [[ -z "$registry" ]]; then

    echo "container registry name is required"
    usage
    exit 1
fi

VERSION_FILE_PATH=../../version.txt

if [[ -z "$appVersion" ]]; then

    export appVersion=`head -n 1 ${VERSION_FILE_PATH}`

    if [[ -z "$VERSION_FILE_PATH" ]]; then
        echo "Error: Unable to determine app's Version Using: ${VERSION_FILE_PATH}"
        exit 1
    fi

fi

set -x

./make-image.sh -v ${appVersion}

set +x

CONTAINER_REGISTRY=${registry}

set -x

docker tag devops-interview:${appVersion} ${CONTAINER_REGISTRY}/devops-interview:${appVersion}

docker push ${CONTAINER_REGISTRY}/devops-interview:${appVersion}
