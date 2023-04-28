#!/bin/bash
#abort in case of cmd failure
set -Eeuo pipefail

source ../env.sh
source ../database/database.sh

#install database
highlight_message "Uninstalling database services"

uninstall_database;

