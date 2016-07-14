#!/bin/bash

oc delete service manageiq
oc delete route manageiq
oc delete dc manageiq
