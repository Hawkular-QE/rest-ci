#!/bin/bash
echo "Deleting pods..."

RC_ID=$(kubectl get rc -l "name=hawkulartest,env=restsmoke1" -o template --template='{{(index .items 0).metadata.name}}')
kubectl resize --replicas=0 rc ${RC_ID}

sleep 5s

echo "Deploying..."
kubectl resize --replicas=1 rc ${RC_ID}

sleep 10s

wget --retry-connrefused  --timeout=10 -t 10  -w 5 --spider ${HAWKULAR_ENDPOING-http://209.132.179.82:19091/.completed}
status=$?

POD_ID=$(kubectl get pods -l "name=hawkulartest, env=testsmoke1"  -o template --template='{{(index .items 0).metadata.name}}')

kubectl log ${POD_ID} restmoke1 

exit $status
