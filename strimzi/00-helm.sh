#!/usr/bin/env bash 
#
kubectl create ns kafka
helm repo add strimzi https://strimzi.io/charts/
helm install strimzi-operator strimzi/strimzi-kafka-operator -n kafka
