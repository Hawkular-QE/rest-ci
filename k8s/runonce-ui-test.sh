#!/bin/bash

if [ -z ${UI_AUTH_KEY_VALUE} ]; then
   echo "UI_AUTH_KEY_VALUE env is not defined"
   exit 1
fi

if [ -z ${HAWKULAR_ENDPOINT_VALUE} ]; then
   echo "HAWKULAR_ENDPOINT_VALUE env is not definited"
   exit 1
fi

sed -e 's%\$HAWKULAR_ENDPOINT_VALUE%'"${HAWKULAR_ENDPOINT_VALUE}"'%g' \
    -e 's%\$AUTH_KEY_VALUE%'"${UI_AUTH_KEY_VALUE}"'%g'   ui-test-controller-template.yaml > ui-test-controller.yaml

LABEL="name=hawkulartest,env=uismoke1"

echo "Deleting... ${LABEL}"
kubectl delete -f ui-test-controller.yaml
kubectl delete -f ui-test-service.yaml
kubectl delete pods -l ${LABEL}

echo "Creating..."

kubectl --validate create -f ui-test-controller.yaml
kubectl --validate create -f ui-test-service.yaml
