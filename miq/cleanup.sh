#!/bin/bash

oc delete service manageiq
oc delete route manageiq manageiq-psql
oc delete dc manageiq
