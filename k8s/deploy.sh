#!/bin/bash
echo "Deleting pods..."
kubectl resize --replicas=0 rc hawkular-restci-controller1

sleep 5s

echo "Deploying..."
kubectl resize --replicas=1 rc hawkular-restci-controller1
sleep 10s
wget --retry-connrefused  --timeout=10 -t 50  -w 5 --spider ${HAWKULAR_ENDPOING-http://209.132.179.82:19090}
status=$?

POD_ID=$(kubectl get pods -l "name=hawkular, env=qe1"  -o template --template='{{(index .items 0).metadata.name}}')

printf "\n############################ Summary ############################\n\n"

kubectl describe pods/${POD_ID}

exit $status
