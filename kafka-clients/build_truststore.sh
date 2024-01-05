#!/usr/bin/env bash

export CERT_FILE_PATH=ca.crt
export CERT_PASSWORD_FILE_PATH=ca.password
export KEYSTORE_LOCATION=truststore
export CERT_PASSWORD=`cat $CERT_PASSWORD_FILE_PATH`
export CA_CERT_ALIAS=strimzi-kafka-cert
keytool -v -storetype jks -importcert -alias $CA_CERT_ALIAS -file $CERT_FILE_PATH -keystore $KEYSTORE_LOCATION -keypass $CERT_PASSWORD -storepass $CERT_PASSWORD -noprompt
