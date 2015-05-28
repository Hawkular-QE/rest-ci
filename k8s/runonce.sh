#!/bin/bash
echo "Deleting..."
kubectl delete -f controller1.yaml
kubectl delete -f service1.yaml
kubectl delete pods -l "name=hawkular,env=qe1"
echo "Creating..."
kubectl --validate create -f controller1.yaml
kubectl --validate create -f service1.yaml
