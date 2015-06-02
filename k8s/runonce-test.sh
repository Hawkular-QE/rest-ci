#!/bin/bash

LABEL="name=hawkulartest,env=restsmoke1"

echo "Deleting... ${LABEL}"
kubectl delete -f rest-test-controller.yaml
kubectl delete -f rest-test-service.yaml
kubectl delete pods -l ${LABEL}
kubectl delete services -l ${LABEL}
echo "Creating..."
kubectl --validate create -f rest-test-controller.yaml
kubectl --validate create -f rest-test-service.yaml
