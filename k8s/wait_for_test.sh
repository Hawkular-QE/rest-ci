#!/bin/bash
: ${HAWKULAR_TEST_READY_TIMEOUT:=300}
NEXT_WAIT_TIME=0
while [ ${NEXT_WAIT_TIME} -lt ${HAWKULAR_TEST_READY_TIMEOUT} ]; do
   wget --quiet  --retry-connrefused  --timeout=10 -t 1  -w 5 --spider ${HAWKULAR_TEST_RESULTS_ENDPOINT}/testng-results.xml
   status=$?
   if [ $status -eq 0 ]; then
      break
   fi
   sleep 5s
   NEXT_WAIT_TIME=$((NEXT_WAIT_TIME+5))
done

exit $status
