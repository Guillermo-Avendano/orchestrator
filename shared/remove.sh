#!/bin/bash
#abort in case of cmd failure
set -Eeuo pipefail

source ../env.sh
source ../database/database.sh

export NAMESPACE=$TF_VAR_NAMESPACE_SHARED;

#install database
highlight_message "Uninstalling database services"

uninstall_database;

kubectl delete ns $NAMESPACE
