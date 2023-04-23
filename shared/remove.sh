#!/bin/bash
#abort in case of cmd failure
set -Eeuo pipefail

source ../env.sh
source ../database/database.sh
source ../elasticsearch/elasticsearch.sh
source ../kafka/kafka.sh

export NAMESPACE=$TF_VAR_NAMESPACE_SHARED;

#install database
highlight_message "Uninstalling database services"

uninstall_database;

#install elasticsearch
if [ "$ELASTICSEARCH_ENABLED" == "true" ]; then
   ELASTICSEARCH_VERSION="${ELASTICSEARCH_VERSION:-7.17.3}";
   ELASTICSEARCH_CONF_FILE=elasticsearch.yaml;
   ELASTICSEARCH_VOLUME=`eval echo ~/${NAMESPACE}_data/elasticsearch`
   ELASTICSEARCH_STORAGE_FILE=elasticsearch-storage.yaml;
   highlight_message "Uninstalling elasticsearch"
   uninstall_elasticsearch;
fi

#install kafka
if [ "$KAFKA_ENABLED" == "true" ]; then
   KAFKA_VOLUME=`eval echo ~/${NAMESPACE}_data/kafka`
   KAFKA_CONF_FILE=kafka-statefulset.yaml;
   KAFKA_VERSION="${KAFKA_VERSION:-3.3.1-debian-11-r3}";
   KAFKA_STORAGE_FILE=kafka-storage.yaml;

   highlight_message "Uninstalling kafka"
   uninstall_kafka;
fi

kubectl delete ns $NAMESPACE