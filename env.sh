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
export NAMESPACE="${NAMESPACE:=rocket}"
PRODUCT="Enterprise Orchestrator"

export KUBECONFIG=$kube_dir/cluster/.cluster-config.yaml    # cluster/cluster.sh
chmod o-wrx,g-wrx $kube_dir/cluster/.cluster-config.yaml
DOCKER_USER=$DOCKER_USERNAME                        # $HOME/.profile cluster/local_registry.sh
DOCKER_PASS=$DOCKER_PASSWORD                        # $HOME/.profile cluster/local_registry.sh

KUBE_SOURCE_REGISTRY="registry.rocketsoftware.com"  # cluster/local_registry.sh
KUBE_LOCALREGISTRY_NAME="aeo.localhost"             # cluster/local_registry.sh
KUBE_LOCALREGISTRY_HOST="localhost"                 # cluster/local_registry.sh
KUBE_LOCALREGISTRY_PORT="5000"                      # cluster/local_registry.sh
KUBE_IMAGE_PULL="YES"                               # cluster/cluster.sh
export KUBE_NS_LIST=( "$NAMESPACE" )
NGINX_EXTERNAL_TLS_PORT=443

################################################################################
# REO IMAGES
################################################################################
IMAGE_SCHEDULER_NAME=aeo/scheduler
IMAGE_SCHEDULER_VERSION=4.3.1.61
IMAGE_CLIENTMGR_NAME=aeo/clientmgr
IMAGE_CLIENTMGR_VERSION=4.3.1.61
IMAGE_AGENT_NAME=aeo/agent
IMAGE_AGENT_VERSION=4.3.1.58

export KUBE_IMAGES=("$IMAGE_SCHEDULER_NAME:$IMAGE_SCHEDULER_VERSION" "$IMAGE_CLIENTMGR_NAME:$IMAGE_CLIENTMGR_VERSION" "$IMAGE_AGENT_NAME:$IMAGE_AGENT_VERSION") # cluster/local_registry.sh

SCHEDULER_REPLICAS=2
CLIENTMGR_REPLICAS=1

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


