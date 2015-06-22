#!/bin/bash

if [ -z $1 ]; then
   echo "Missing URL"
   exit 1
fi

: ${HEALTH_CHECK_TIMEOUT:=300}
NEXT_WAIT_TIME=0
while [ ${NEXT_WAIT_TIME} -lt ${HEALTH_CHECK_TIMEOUT} ]; do
   wget --quiet  --retry-connrefused  --timeout=10 -t 1  -w 5 --spider $1
   status=$?
   if [ $status -eq 0 ]; then
      break
   fi
   sleep 5s
   NEXT_WAIT_TIME=$((NEXT_WAIT_TIME+5))
done

exit $status
