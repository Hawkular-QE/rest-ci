#!/bin/bash
echo "Deleting pods..."
kubectl delete -f pod.json
sleep 10s
echo "Deploying..."
kubectl create -f pod.json
