
k create -f c-rc.yml
k scale --replicas=1 replicationcontrollers alpha-qe-cassandra-rc
k create -f c-serv.yml
