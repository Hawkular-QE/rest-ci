#!/bin/bash

: ${APP_LABEL:=name=hawkulartest,env=restsmoke1}
: ${APP_PREDELAY:=45s}

echo "Deleting pods...${APP_LABEL}"

RC_ID=$(kubectl get rc -l "${APP_LABEL}" -o template --template='{{(index .items 0).metadata.name}}')
kubectl resize --replicas=0 rc ${RC_ID}

sleep 5s

echo "Deploying..."
kubectl resize --replicas=1 rc ${RC_ID}

echo "Waiting for ${APP_PREDELAY}"
sleep ${APP_PREDELAY}

kubectl get pods -l "${APP_LABEL}" -o template --template='{{(index .items 0).status.phase}}' --watch-only=true

POD_ID=$(kubectl get pods -l "${APP_LABEL}"  -o template --template='{{(index .items 0).metadata.name}}')
kubectl log -f ${POD_ID} restsmoke1 &

wget --quiet  --retry-connrefused  --timeout=10 -t 20  -w 5 --spider http://209.132.179.82:19091/.completed
status=$?

exit $status
