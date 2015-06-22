#!/bin/bash

: ${APP_LABEL:=name=hawkulartest,env=restsmoke1}
: ${APP_PREDELAY:=15s}
: ${HAWKULAR_TEST_RESULTS_ENDPOINT:=http://209.132.179.82:18081}

echo "Deleting old pod... label: ${APP_LABEL}"

RC_ID=$(kubectl get rc -l "${APP_LABEL}" -o template --template='{{(index .items 0).metadata.name}}')
kubectl resize --replicas=0 rc ${RC_ID}

sleep 5s

echo "Deploying..."
kubectl resize --replicas=1 rc ${RC_ID}

echo "Pausing ${APP_POST_DEPLOY_DELAY}"
sleep ${APP_POST_DEPLOY_DELAY}

POD_ID=$(kubectl get pods -l "${APP_LABEL}"  -o template --template='{{(index .items 0).metadata.name}}')

echo "Waiting for pod to be in Running state"

./wait_for_pod.sh ${POD_ID}

CONTAINER_ID=$(kubectl get pods -l "${APP_LABEL}"  -o template --template='{{with $x:=(index .items 0).spec.containers}} {{(index $x 0).name }} {{end}}')

kubectl log -f ${POD_ID} ${CONTAINER_ID} &
LOG_ID=$!


./health_check.sh ${HAWKULAR_TEST_RESULTS_ENDPOINT}/testng-results.xml

kill -9 ${LOG_ID}
exit 0
