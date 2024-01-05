#!/usr/bin/env bash

export CLUSTER_NAME=my-cluster
export NAMESPACE=kafka

kubectl -n $NAMESPACE get secret $CLUSTER_NAME-cluster-ca-cert -o jsonpath='{.data.ca\.crt}' | base64 --decode > ca.crt
kubectl -n $NAMESPACE get secret $CLUSTER_NAME-cluster-ca-cert -o jsonpath='{.data.ca\.password}' | base64 --decode > ca.password
