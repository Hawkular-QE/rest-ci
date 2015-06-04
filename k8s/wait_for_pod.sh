#!/bin/bash
if [ -z $1 ]; then
   echo "Usage $0 podId"
   exit 1
fi

: ${POD_TIMEOUT:=600}
POD_ID=$1
NEXT_WAIT_TIME=0
while [ $NEXT_WAIT_TIME -lt ${POD_TIMEOUT} ]; do
   POD_PHASE=$(kubectl get pods ${POD_ID} -o template --template='{{.status.phase}}')
   if [ "x${POD_PHASE}" == "xRunning" ]; then
      exit 0      
   fi

   NEXT_WAIT_TIME=$((NEXT_WAIT_TIME+5))
   sleep 5s
   printf ". "
done
printf "\n"
exit 1
