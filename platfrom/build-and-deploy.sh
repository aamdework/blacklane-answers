#!/usr/bin/env bash

usage() { echo "Usage: $0 -r <registry>" 1>&2; exit 1; }

set -e

declare registry=""

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

set -e
set -x

docker/make-image.sh -r "${registry}"

set -e
set -x

docker/push-image.sh -r "${registry}"

set -e
set -x

k8s/deploy.sh -e "${env}"

set -e
set -x

./increment-version.sh
