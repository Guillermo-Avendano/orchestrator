

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


info_message "Verifying Orchestrator services";

# Define los nombres de los pods que se deben verificar
POD_NAMES=("aeo-agent" "aeo-scheduler" "aeo-clientmgr")

# Define la cantidad de veces que se verificarán los pods
NUM_CHECKS=5

# Define la cantidad de tiempo que se esperará entre cada verificación (en segundos)
WAIT_TIME=3

# Loop sobre los nombres de los pods
for POD_NAME in "${POD_NAMES[@]}"
do
  # Inicializa una variable para contar el número de veces que se ha verificado el pod
  CHECKS=0
  
  # Loop hasta que el pod esté en estado "Running"
  while [[ $(kubectl -n $NAMESPACE get pods | grep $POD_NAME | awk '{print $3}') != "Running" ]]
  do
    # Incrementa el contador de verificación
    ((CHECKS++))
    
    # Verifica si se ha alcanzado el número máximo de verificaciones
    if [[ $CHECKS -eq $NUM_CHECKS ]]; then
      echo "ERROR: Cannot verify pod $POD_NAME after $NUM_CHECKS attempts"
      exit 1
    fi
    
    # Espera antes de la siguiente verificación
    sleep $WAIT_TIME
  done
  
done

highlight_message "kubectl -n $NAMESPACE get pods"
kubectl -n $NAMESPACE get pods

highlight_message "kubectl -n $NAMESPACE get ingress"
kubectl -n $NAMESPACE get ingress

