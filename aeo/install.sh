

#!/bin/bash
#abort in case of cmd failure
set -Eeuo pipefail

source ../env.sh
source ../database/database.sh
source "./helm/aeo.sh"

#install database
highlight_message "Deploying database services"
install_database;
info_progress_header "Waiting for database services to be ready ...";
wait_for_database_ready;
info_message "The database services are ready now.";

highlight_message "Deploying Orchestrator services";
install_aeo;
info_progress_header "Waiting for Orchestrator services to be ready ...";
wait_for_aeo_ready;
info_message "Orchestrator services are ready now.";
