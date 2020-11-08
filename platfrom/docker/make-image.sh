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

set -e

printf "\n\nMaking Project Docker Image...\n\n"

CR_REPOSITORY_NAME=${registry}

VERSION_FILE_PATH=../../version.txt

if [[ -z "$appVersion" ]]; then

    export appVersion=`head -n 1 ${VERSION_FILE_PATH}`

    if [[ -z "$VERSION_FILE_PATH" ]]; then
        echo "Error: Unable to determine app's Version Using: ${VERSION_FILE_PATH}"
        exit 1
    fi

fi

set +x
set -e

CWD=`pwd`

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

set -x

cd "${SCRIPT_DIR}"

set +x

echo "Making APP \${VERSION} Image..."

#if [[ "$(docker images -q ${CR_REPOSITORY_NAME}:${appVersion})" == "" ]]; then

    if [ -d target ] ; then
        rm -fr target
    fi

    set -x

    mkdir target
    mkdir -p target/helpers
    cp -r ../../helpers/ target/helpers
    mkdir -p target/migrations
    cp -r ../../migrations/ target/migrations
    mkdir -p target/postgres-data
    cp -r ../../postgres-data/ target/postgres-data
    mkdir -p target/static
    cp -r ../../static/ target/static
    mkdir -p target/templates
    cp -r ../../templates/ target/templates
    cp ../../_config.yml target/_config.yml
    cp ../../app.py  target/app.py
    cp ../../entrypoint.sh  target/entrypoint.sh
    cp ../../gunicorn.config.py target/gunicorn.config.py
    cp ../../setup.cfg target/setup.cfg
    cp ../../setup.py target/setup.py
    cp ../../version.txt target/version.txt
    cp ../../requirements.txt target/requirements.txt

    docker build --tag devops-interview:${appVersion} .

    cd "${CWD}"

#else

    echo "Info: Image ${CR_REPOSITORY_NAME}:${appVersion} already exists - will NOT re-build it."

#fi


