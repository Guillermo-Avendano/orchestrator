
#!/bin/bash

source "../env.sh"
source "$kube_dir/common/common.sh"

install_aeo(){
    AEO_VALUES_TEMPLATE=helm/template/values.yaml

    AEO_VALUES=helm/aeo-4.3.1/values.yaml

    cp $AEO_VALUES_TEMPLATE $AEO_VALUES

    IMAGE_SCHEDULER=$KUBE_LOCALREGISTRY_HOST:$KUBE_LOCALREGISTRY_PORT/$IMAGE_SCHEDULER_NAME:$IMAGE_SCHEDULER_VERSION
    IMAGE_CLIENTMGR=$KUBE_LOCALREGISTRY_HOST:$KUBE_LOCALREGISTRY_PORT/$IMAGE_CLIENTMGR_NAME:$IMAGE_CLIENTMGR_VERSION
    IMAGE_AGENT=$KUBE_LOCALREGISTRY_HOST:$KUBE_LOCALREGISTRY_PORT/$IMAGE_AGENT_NAME:$IMAGE_AGENT_VERSION
    DATABASE_URL="jdbc:postgresql://$POSTGRESQL_HOST:$POSTGRESQL_PORT/$POSTGRESQL_DBNAME"

    replace_tag_in_file $AEO_VALUES "<scheduler_image>" $IMAGE_SCHEDULER;
    replace_tag_in_file $AEO_VALUES "<clientmgr_image>" $IMAGE_CLIENTMGR;
    replace_tag_in_file $AEO_VALUES "<agent_image>" $IMAGE_AGENT;

    replace_tag_in_file $AEO_VALUES "<database_user>" $POSTGRESQL_USERNAME;
    replace_tag_in_file $AEO_VALUES "<database_passencr>" $POSTGRESQL_PASSENCR;
    replace_tag_in_file $AEO_VALUES "<database_name>" $POSTGRESQL_DBNAME;
    replace_tag_in_file $AEO_VALUES "<database_host>" $POSTGRESQL_HOST;
    replace_tag_in_file $AEO_VALUES "<database_url>" $DATABASE_URL;

    replace_tag_in_file $AEO_VALUES "<aeo_url>" $AEO_URL;

    info_message "Deploying Orchestrator Helm chart";

    helm upgrade -f $AEO_VALUES aeo-$NAMESPACE helm/aeo-4.3.1 --namespace $NAMESPACE --install --wait;
}

wait_for_aeo_ready(){
    # Define los nombres de los pods que se deben verificar
    POD_NAMES=("agent" "scheduler" "clientmgr")

    # Define la cantidad de veces que se verificarán los pods
    NUM_CHECKS=10
    # Define la cantidad de tiempo que se esperará entre cada verificación (en segundos)
    WAIT_TIME=10
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
                error_message "ERROR: Cannot verify pod $POD_NAME after $NUM_CHECKS attempts"
                exit 1
            fi           
            # Espera antes de la siguiente verificación
            info_progress "..."
            sleep $WAIT_TIME
        done
    done

    highlight_message "kubectl -n $NAMESPACE get pods"
    kubectl -n $NAMESPACE get pods

    highlight_message "kubectl -n $NAMESPACE get ingress"
    kubectl -n $NAMESPACE get ingress
}

uninstall_aeo(){
    helm uninstall aeo-$NAMESPACE --namespace $NAMESPACE
}
