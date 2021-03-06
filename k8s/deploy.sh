#!/bin/bash

# "hawkular-restart": Restart Hawkular, only.
# "reset": Full redeploy of Hawkular, only.
# "full-reset": Full redeploy of Hawkular and Cassandra
RESET=$1

if [ -z ${APP_LABEL} ]; then
   echo "Missing APP_LABEL env.  Did you source env file?"
   exit 1
fi
echo "~~~~ APP_LABEL: ${APP_LABEL} ~~~~"
if [ "${RESET}" == "reset" ] || [ "${RESET}" == "full-reset" ]; then
   echo "Resetting Hawkular..."
   kubectl delete -f ${KUBE_RC}
   kubectl delete pods -l "${APP_LABEL}"
   kubectl delete service -l "${APP_LABEL}"
   echo "Creating replication controller..."
   kubectl create -f ${KUBE_RC}

   sleep 5s
   echo "Creating service ${SERVICE_NAME}..."
   python service.py | kubectl create -f -
   RC_ID=$(kubectl get rc -l "${APP_LABEL}" -o template --template='{{(index .items 0).metadata.name}}')

   if [ "${RESET}" == "full-reset" ]; then
      echo "Resetting Cassandra..."
      kubectl delete -f `pwd`/${CASSANDRA_KUBE_RC}
      kubectl delete pods -l "${CASSANDRA_APP_LABEL}"
      kubectl delete service -l "${CASSANDRA_APP_LABEL}"
      echo "Creating Cassandra replication controller..."
      kubectl create -f ${CASSANDRA_KUBE_RC}

      sleep 5s
      echo "Creating service ${CASSANDRA_KUBE_SERVICE}..."
      kubectl create -f `pwd`/${CASSANDRA_KUBE_SERVICE}
      CASSANDRA_RC_ID=$(kubectl get rc -l "${CASSANDRA_APP_LABEL}" -o template --template='{{(index .items 0).metadata.name}}')
   fi
else
   # preconditions: Pod and RC have been running already from previous run
   echo "Deleting Hawkular pods..."
   RC_ID=$(kubectl get rc -l "${APP_LABEL}" -o template --template='{{(index .items 0).metadata.name}}')
   kubectl scale --replicas=0 rc ${RC_ID}

   if [ "${RESET}" != "hawkular-restart" ]; then
      echo "Deleting Cassandra pods..."
      CASSANDRA_RC_ID=$(kubectl get rc -l "${APP_LABEL}" -o template --template='{{(index .items 0).metadata.name}}')
      kubectl scale --replicas=0 rc ${CASSANDRA_RC_ID}
   fi
fi

sleep 5s

if [ "${RESET}" != "hawkular-restart" ]; then
   echo "Deploying (scaling rc ${CASSANDRA_RC_ID} to 1 instance) ..."
   kubectl scale --replicas=1 rc ${CASSANDRA_RC_ID}

   sleep 5
   POD_ID=$(kubectl get pods -l "${CASSANDRA_APP_LABEL}"  -o template --template='{{(index .items 0).metadata.name}}')

   echo "Wating for Cassandra pod to be in Running state"

   ./wait_for_pod.sh ${POD_ID}

   if [ $? -ne 0 ]; then
      exit 1
   fi
fi

echo "Deploying (scaling rc ${RC_ID} to 1 instance) ..."
kubectl scale --replicas=1 rc ${RC_ID}

sleep 5s
POD_ID=$(kubectl get pods -l "${APP_LABEL}"  -o template --template='{{(index .items 0).metadata.name}}')

echo "Wating for pod to be in Running state"

./wait_for_pod.sh ${POD_ID}

if [ $? -ne 0 ]; then
   exit 1
fi

HOST_IP=$(kubectl get pods "${POD_ID}" -o template --template='{{.status.hostIP}}')

echo "Pod deployed to ${HOST_IP}"
echo "~~~~~ App stdout begins ~~~~"

kubectl logs -f ${POD_ID} hawkular &
LOG_PID=$!

ENDPOINT=${HOST_IP}:${EXT_PORT}
./health_check.sh ${ENDPOINT}/hawkular/metrics/status

status=$?

kill -9 ${LOG_PID}
unset APP_LABEL
exit $status
