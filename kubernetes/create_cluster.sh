#!/bin/sh
DOMAIN=dotstarmoney.com
PREFIX=sal.
STATE_STORE_BUCKET=sal-dotstarmoney-com-state-store

# backoff function
function with_backoff {
  local max_attempts=${ATTEMPTS-10}
  local timeout=${TIMEOUT-1}
  local attempt=0
  local exitCode=0

  while [[ $attempt < $max_attempts ]]
  do
    "$@"
    exitCode=$?

    if [[ $exitCode == 0 ]]
    then
      break
    fi

    echo "Failure! Retrying in $timeout.." 1>&2
    sleep $timeout
    attempt=$(( attempt + 1 ))
    timeout=$(( timeout * 2 ))
  done

  if [[ $exitCode != 0 ]]
  then
    echo "You've failed me for the last time! ($@)" 1>&2
  fi

  return $exitCode
}

# set variables
parentZone=`aws route53 list-hosted-zones | jq '.HostedZones[] | select(.Name=="${DOMAIN}") | .Id'`
NAME=$PREFIX$DOMAIN
KOPS_STATE_STORE=s3://${STATE_STORE_BUCKET}

# adds subdomain record sets
aws route53 change-resource-record-sets \
    --hosted-zone-id ${parentZone} \
    --change-batch file://subdomain.json

aws s3api create-bucket \
    --bucket ${STATE_STORE_BUCKET} \
    --region us-west-2
    --create-bucket-configuration LocationConstraint=us-west-2

kops create cluster \
    --zones us-west-2a \
    ${NAME}

with_backoff kops validate cluster
