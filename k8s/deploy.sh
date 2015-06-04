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

echo "Pod status: $(timeout 30 kubectl get pods ${POD_ID} -o template --template='{{.status.phase}}' --watch=true)"

kubectl log -f ${POD_ID} &
LOG_PID=$!

wget --no-verbose --retry-connrefused  --timeout=10 -t 50  -w 5 --spider ${HAWKULAR_ENDPOINT-http://209.132.179.82:18080}
status=$?

kill -9 ${LOG_PID}

printf "\n############################ Summary ############################\n\n"

kubectl describe pods/${POD_ID}

exit $status
