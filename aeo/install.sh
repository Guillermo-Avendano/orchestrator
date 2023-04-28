#!/bin/bash
#abort in case of cmd failure
set -Eeuo pipefail

source ../env.sh
source "./helm/aeo.sh"

highlight_message "Deploying Orchestrator services";
install_aeo;
info_progress_header "Waiting for Orchestrator services to be ready ...";
wait_for_aeo_ready;
info_message "Orchestrator services are ready now.";