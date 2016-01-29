
k delete service cassandra
k delete service hawkular-alpha

k scale --replicas=0 replicationcontrollers alpha-qe-rc
k delete rc alpha-qe-rc
k scale --replicas=0 replicationcontrollers alpha-qe-cassandra-rc
k delete rc alpha-qe-cassandra-rc
