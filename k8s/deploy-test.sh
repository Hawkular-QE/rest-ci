#!/bin/bash

: ${APP_LABEL:=name=hawkulartest,env=restsmoke1}
: ${APP_PREDELAY:=15s}
: ${HAWKULAR_TEST_ENDPOINT:=http://209.132.179.82:18081}

RC_ID=$(kubectl get rc -l "${APP_LABEL}" -o template --template='{{(index .items 0).metadata.name}}')
kubectl resize --replicas=0 rc ${RC_ID}

sleep 5s

echo "Deploying..."
kubectl resize --replicas=1 rc ${RC_ID}

echo "Waiting for ${APP_PREDELAY}"
sleep ${APP_PREDELAY}

POD_ID=$(kubectl get pods -l "${APP_LABEL}"  -o template --template='{{(index .items 0).metadata.name}}')

echo "Waiting for pod to be in Running state"

NEXT_WAIT_TIME=0
while [ $NEXT_WAIT_TIME -lt 240 ]; do
   POD_PHASE=$(kubectl get pods ${POD_ID} -o template --template='{{.status.phase}}')
   if [ "x${POD_PHASE}" == "xRunning" ]; then
      break
   fi  

   NEXT_WAIT_TIME=$((NEXT_WAIT_TIME+5))
   sleep 5s
   printf ". "
done

printf "\n"

kubectl log -f ${POD_ID} restsmoke1 &
LOG_ID=$!

wget --quiet  --retry-connrefused  --timeout=10 -t 20  -w 5 --spider ${HAWKULAR_TEST_ENDPOINT}/.completed

kill -9 ${LOG_ID}
exit 0
