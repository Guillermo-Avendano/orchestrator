#!/bin/bash
#abort in case of cmd failure
set -Eeuo pipefail

source ../env.sh
source ../database/database.sh

export NAMESPACE=$TF_VAR_NAMESPACE_SHARED;

#install database
highlight_message "Deploying database services"

install_database;

info_progress_header "Waiting for database services to be ready ...";
wait_for_database_ready;
info_message "The database services are ready now.";

