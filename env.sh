#!/bin/bash

kube_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
[ -d "$kube_dir" ] || {
    echo "FATAL: no current dir (maybe running in zsh?)"
    exit 1
}

################################################################################
# KUBERNETES CONFIG
################################################################################
KUBE_CLUSTER_NAME="rocket"                               # cluster/cluster.sh
NAMESPACE=rocket

export KUBECONFIG=$kube_dir/cluster/.cluster-config.yaml    # cluster/cluster.sh

DOCKER_USER="gavendano@rs.com"                     # cluster/local_registry.sh  
DOCKER_PASS=`echo $DOCKER_PASSWORD | base64 -d`    # $HOME/.profile -> DOCKER_PASSWORD encoded base64

KUBE_SOURCE_REGISTRY="registry.rocketsoftware.com"  # cluster/local_registry.sh 
KUBE_LOCALREGISTRY_NAME="rocket.localhost"                 # cluster/local_registry.sh
KUBE_LOCALREGISTRY_HOST="localhost"                 # cluster/local_registry.sh 
KUBE_LOCALREGISTRY_PORT="5000"                      # cluster/local_registry.sh 
NGINX_EXTERNAL_TLS_PORT=443

################################################################################
# MOBIUS IMAGES
################################################################################
IMAGE_SCHEDULER_NAME=aeo/scheduler
IMAGE_SCHEDULER_VERSION=4.3.1.61
IMAGE_CLIENTMGR_NAME=aeo/clientmgr
IMAGE_CLIENTMGR_VERSION=4.3.1.61
IMAGE_AGENT_NAME=aeo/agent
IMAGE_AGENT_VERSION=4.3.1.58

export KUBE_IMAGES=("$IMAGE_SCHEDULER_NAME:$IMAGE_SCHEDULER_VERSION" "$IMAGE_CLIENTMGR_NAME:$IMAGE_CLIENTMGR_VERSION" "$IMAGE_AGENT_NAME:$IMAGE_AGENT_VERSION") # cluster/local_registry.sh

################################################################################
# DATABASES
################################################################################
EXTERNAL_DATABASE=false
DATABASE_PROVIDER=postgresql
POSTGRESQL_VERSION=14.5.0
POSTGRESQL_USERNAME=aeo
POSTGRESQL_PASSWORD=aeo
POSTGRESQL_PASSENCR=3X6ApGn/D3cgkTxc730BGhvV6C6A6YPfGare9QjWgdT5rkI9wCWWFRvfYk1f5PXqN
POSTGRESQL_DBNAME=aeo
POSTGRESQL_HOST=postgresql
POSTGRESQL_PORT=5432
export POSTGRES_VALUES_TEMPLATE=postgres-aeo.yaml

#########################################
export AEO_URL="aeo.rocketsoftware.com"


#########################################
## Terraform NOT READY!!!!
#########################################
export TF_VAR_NAMESPACE=$NAMESPACE
export TF_VAR_NAMESPACE_SHARED="shared"
export TF_VAR_AEO_URL="aeo.rocketsoftware.com"

export TF_VAR_POSTGRESQL_HOST=$POSTGRESQL_HOST
export TF_VAR_POSTGRESQL_PORT=$POSTGRESQL_PORT
export TF_VAR_POSTGRESQL_USERNAME=$POSTGRESQL_USERNAME
export TF_VAR_POSTGRESQL_PASSWORD=$POSTGRESQL_PASSWORD
export TF_VAR_POSTGRESQL_PASSENCR=$POSTGRESQL_PASSENCR
export TF_VAR_POSTGRESQL_DBNAME=$POSTGRESQL_DBNAME


########################################################################
# In processing
# NAMESPACE=test
# declare -A pv
# pv['MOBIUS_PV_VOLUME']=~/${NAMESPACE}_data/mobius/pv
# pv['MOBIUS_FTS_VOLUME']=~/${NAMESPACE}_data/mobius/fts
# pv['MOBIUS_DIAGNOSTIC_VOLUME']=~/${NAMESPACE}_data/mobius/log

# pv['MOBIUSVIEW_PV_VOLUME']=~/${NAMESPACE}_data/mobiusview/pv
# pv['MOBIUSVIEW_DIAGNOSTIC_VOLUME']=~/${NAMESPACE}_data/mobiusview/log

# pv['COMMON_VOLUME']=~/${NAMESPACE}_data/common
# pv['POSTGRES_VOLUME']=~/${NAMESPACE}_data/postgres
# pv['KAFKA_VOLUME']=~/${NAMESPACE}_data/kafka
# pv['ELASTICSEARCH_VOLUME']=~/${NAMESPACE}_data/elasticsearch
# pv['PGADMIN_VOLUME']=~/${NAMESPACE}_data/pgadmin

# VOLUME_MAPPING=""
# for local_pv in ${!pv[@]}; do
    #if [ ! -d ${pv[${local_pv}]} ]; then

        #mkdir -p ${pv[${local_pv}]};
        #chmod -R 777 ${pv[${local_pv}]};
    #fi 
   # VOL_MAP=`eval echo ${pv[${local_pv}]}`
   # VOLUME_MAPPING+="--volume $VOL_MAP:$VOL_MAP "
    #echo Creating: $local_pv ${pv[${local_pv}]}
#done

# KUBE_CLUSTER_EXTRA_ARGS="$VOLUME_MAPPING --wait";
