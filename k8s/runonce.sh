#!/bin/bash

: ${APP_LABEL:=name=hawkular,env=snapshot}

echo "Deleting... label: ${APP_LABEL}"
kubectl delete -f controller1.yaml
kubectl delete -f service1.yaml
kubectl delete pods -l "${APP_LABEL}"
echo "Creating..."
kubectl --validate create -f controller1.yaml
kubectl --validate create -f service1.yaml
