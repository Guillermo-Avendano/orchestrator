#!/bin/bash
#abort in case of cmd failure
set -Eeuo pipefail

source ../env.sh

source "./helm/aeo.sh"

highlight_message "Uninstalling Orchestrator services"

uninstall_aeo;

#kubectl delete ns $NAMESPACE
