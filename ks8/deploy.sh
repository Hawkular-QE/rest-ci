#!/bin/bash
kubectl delete -f pod.json
kubectl create -f pod.json
