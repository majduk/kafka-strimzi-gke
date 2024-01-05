#!/usr/bin/env bash

export CLUSTER_NAME=my-cluster
export NAMESPACE=kafka

kubectl -n $NAMESPACE get secret my-user -o jsonpath='{.data.password}' | base64 --decode > user_password

cat<<EOF > client.properties
security.protocol=SASL_SSL
sasl.mechanism=SCRAM-SHA-512
ssl.truststore.location=/home/kafka/truststore/truststore
ssl.truststore.password=$(cat ca.password)
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required serviceName="kafka" username="my-user" password="$(cat user_password)";
EOF
kubectl -n kafka delete secret kafka-ca-truststore 
kubectl -n kafka create secret generic kafka-ca-truststore --from-file=truststore
kubectl -n kafka delete secret my-user-client-properties 
kubectl -n kafka create secret generic my-user-client-properties --from-file=client.properties
