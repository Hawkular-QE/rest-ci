#!/bin/bash
echo "Deleting..."
kubectl delete -f hawk-app-service.json
kubectl delete -f test-results-service.json
echo "Creating..."
kubectl create -f hawk-app-service.json
kubectl create -f test-results-service.json
