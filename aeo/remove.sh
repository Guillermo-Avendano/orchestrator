#!/bin/bash
#abort in case of cmd failure
set -Eeuo pipefail

source ../env.sh
source ../database/database.sh
source "./helm/aeo.sh"

#install database
highlight_message "Uninstalling database services"

uninstall_database;

highlight_message "Uninstalling Orchestrator services"

uninstall_aeo;

kubectl delete ns $NAMESPACE
