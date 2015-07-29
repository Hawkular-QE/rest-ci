#!/bin/bash

if [ -z ${APP_LABEL} ]; then
   echo "Missing APP_LABEL env.  Did you source env file?"
   exit 1
fi
echo "*** APP_LABEL: ${APP_LABEL} ***"
if [ "$1" == "reset" ]; then
   echo "Resetting..."
   kubectl delete -f ${KUBE_RC}
   kubectl delete pods -l "${APP_LABEL}"
   kubectl delete service -l "${APP_LABEL}"
   echo "Creating replication controller..."
   kubectl --validate create -f ${KUBE_RC}

   sleep 5s
   RC_ID=$(kubectl get rc -l "${APP_LABEL}" -o template --template='{{(index .items 0).metadata.name}}')
   echo "Creating service ${SERVICE_NAME}..."
   python service.py | kubectl create --validate -f -
else
   # preconditions: Pod and RC have been running already from previous run
   echo "Deleting pods..."
   RC_ID=$(kubectl get rc -l "${APP_LABEL}" -o template --template='{{(index .items 0).metadata.name}}')
   kubectl resize --replicas=0 rc ${RC_ID}
fi

sleep 5s

echo "Deploying (scaling rc ${RC_ID} to 1 instance) ..."
kubectl scale --replicas=1 rc ${RC_ID}

sleep 5s
POD_ID=$(kubectl get pods -l "${APP_LABEL}"  -o template --template='{{(index .items 0).metadata.name}}')

echo "Wating for pod to be in Running state"

./wait_for_pod.sh ${POD_ID}

kubectl log -f ${POD_ID} &
LOG_PID=$!

./health_check.sh ${HAWKULAR_ENDPOINT}
status=$?

kill -9 ${LOG_PID}
unset APP_LABEL
exit $status
