Deploy ManageIQ in Kubernetes 
==
Create external service
```
# kubectl create -f miq-service.yml
```
Create replication controller
```
# kubectl create -f miq-rc.yml
```

Deploy ManageIQ in OpenShift v3 
==
1. In your own namespace

  Add your namespace `default` service account to the `privileged` security context
  ```
  oadm policy add-scc-to-user privileged system:serviceaccount:<your_namespace>:default
  ```
  
  Create new manageiq app
  ```
  oc new-app --file=./manageiq-template.yaml
  ```
2. Optionally you can upload the template to `openshift` namespace to make it available globally and use the UI to create new app

  ```
  oc create -f manageiq-template.yaml -n openshift
  ```
