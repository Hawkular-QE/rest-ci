#!/bin/bash

: ${APP_LABEL:=name=hawkular, env=snapshot}
echo "Deleting pods... label: ${APP_LABEL}"

RC_ID=$(kubectl get rc -l "${APP_LABEL}" -o template --template='{{(index .items 0).metadata.name}}')
kubectl resize --replicas=0 rc ${RC_ID}

sleep 5s

echo "Deploying..."
kubectl resize --replicas=1 rc ${RC_ID}

sleep 5s
POD_ID=$(kubectl get pods -l "${APP_LABEL}"  -o template --template='{{(index .items 0).metadata.name}}')

echo "Wating for pod to be in Running state"

./wait_for_pod.sh ${POD_ID}

kubectl log -f ${POD_ID} &
LOG_PID=$!

./health_check.sh ${HAWKULAR_ENDPOINT}
status=$?

kill -9 ${LOG_PID}

exit $status
