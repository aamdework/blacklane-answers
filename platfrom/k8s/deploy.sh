#!/usr/bin/env bash

usage() { echo "Usage: $0 -e <environment> -v <app version>" 1>&2; exit 1; }

set -e

declare env=""
declare appVersion=""
declare helmOptions=""


# Initialize parameters specified from command line
while getopts ":e:" arg; do
	case "${arg}" in
		e)
			env=${OPTARG}
			;;
		o)
			helmOptions=${OPTARG}
			;;

		esac
done
shift $((OPTIND-1))


if [[ -z "$env" ]]; then

    echo "environment is required"
    usage
    exit 1
fi

VERSION_FILE=../../version.txt

appVersion=`head -n 1 ${VERSION_FILE}`

if [[ -z "$appVersion" ]]; then

    echo "Error: Unable to determine version number"
    exit 1

fi

ENV_CONFIG="helm/env/${env}-values.yaml"

if [ ! -f "${ENV_CONFIG}" ] ; then

    echo "Environment config file ${ENV_CONFIG} not found"
    exit 1

fi


NAMESPACE=${env}-devops-interview

set +e

kubectl get ns ${NAMESPACE}

if [ $? -ne 0 ]
then
  kubectl create ns ${NAMESPACE}
fi

set -e
set +x

helm template ./helm \
    -f ${ENV_CONFIG} \
    --set image.tag=${appVersion} \
   | kubectl apply --namespace ${NAMESPACE} -f -

set +e