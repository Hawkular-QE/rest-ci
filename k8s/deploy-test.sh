#!/bin/bash

: ${APP_LABEL:=name=hawkulartest,env=restsmoke1}
: ${APP_PREDELAY:=15s}
: ${HAWKULAR_TEST_ENDPOINT:=http://209.132.179.82:18081}

echo "Deleting old pod... label: ${APP_LABEL}"

RC_ID=$(kubectl get rc -l "${APP_LABEL}" -o template --template='{{(index .items 0).metadata.name}}')
kubectl resize --replicas=0 rc ${RC_ID}

sleep 5s

echo "Deploying..."
kubectl resize --replicas=1 rc ${RC_ID}

echo "Waiting for ${APP_PREDELAY}"
sleep ${APP_PREDELAY}

POD_ID=$(kubectl get pods -l "${APP_LABEL}"  -o template --template='{{(index .items 0).metadata.name}}')

echo "Waiting for pod to be in Running state"

./wait_for_pod.sh ${POD_ID}

kubectl log -f ${POD_ID} restsmoke1 &
LOG_ID=$!

while true; do 
   timeout 240 wget --quiet  --retry-connrefused  --timeout=10 -t 20  -w 5 --spider ${HAWKULAR_TEST_ENDPOINT}/testng-results.xml
   if [ $? -eq 0 ]; then
      break
   fi
   sleep 5s
done
kill -9 ${LOG_ID}
exit 0
