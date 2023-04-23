#!/bin/bash

source "$kube_dir/common/common.sh"


install_database() {
    
    info_message "Installing $DATABASE_PROVIDER database ..."

    if [ "$DATABASE_PROVIDER" == "postgresql" ]; then
        info_message "Creating database namespace and storage";
            
        if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
            kubectl create namespace "$NAMESPACE";
        fi 
        
        #POSTGRES_VOLUME=`eval echo ~/${NAMESPACE}_data/postgres`
        POSTGRES_STORAGE_FILE=postgres-storage.yaml

        cp $kube_dir/database/storage/local/templates/$POSTGRES_STORAGE_FILE $kube_dir/database/storage/local/$POSTGRES_STORAGE_FILE;

        POSTGRES_CONF_FILE=$kube_dir/database/$POSTGRES_VALUES_TEMPLATE;
        cp $kube_dir/database/templates/$POSTGRES_VALUES_TEMPLATE $POSTGRES_CONF_FILE;

        POSTGRESQL_VERSION="${POSTGRESQL_VERSION:-14.5.0}";

        info_message "Configuring Postgresql $POSTGRESQL_VERSION resources";

        replace_tag_in_file $POSTGRES_CONF_FILE "<image_tag>" $POSTGRESQL_VERSION;
        replace_tag_in_file $POSTGRES_CONF_FILE "<database_user>" $POSTGRESQL_USERNAME;
        replace_tag_in_file $POSTGRES_CONF_FILE "<database_password>" $POSTGRESQL_PASSWORD;
        replace_tag_in_file $POSTGRES_CONF_FILE "<database_name_mobiusview>" $POSTGRESQL_DBNAME_MOBIUSVIEW;
        replace_tag_in_file $POSTGRES_CONF_FILE "<database_name_mobius>" $POSTGRESQL_DBNAME_MOBIUS;    
        replace_tag_in_file $POSTGRES_CONF_FILE "<database_name_eventanalytics>" $POSTGRESQL_DBNAME_EVENTANALYTICS;
        replace_tag_in_file $POSTGRES_CONF_FILE "<postgres_port>" $POSTGRESQL_PORT;

        kubectl apply -f $kube_dir/database/storage/local/$POSTGRES_STORAGE_FILE --namespace $NAMESPACE;
        
        info_message "Updating local Helm repository";

        helm repo add bitnami https://charts.bitnami.com/bitnami;
        helm repo update;

        info_message "Deploying postgresql Helm chart";

        helm upgrade -f $POSTGRES_CONF_FILE postgresql bitnami/postgresql --namespace $NAMESPACE --version 11.8.2 --install;
    else
        error_message "Unexpected DATABASE_PROVIDER value: $DATABASE_PROVIDER";
    fi
    
    
}

uninstall_database() {
    POSTGRES_STORAGE_FILE=postgres-storage.yaml
    helm uninstall postgresql --namespace $NAMESPACE;
    kubectl delete -f $kube_dir/database/storage/local/$POSTGRES_STORAGE_FILE --namespace $NAMESPACE;
}

get_database_status() {
    kubectl get pods --namespace $NAMESPACE postgresql-0 -o jsonpath="{.status.phase}" 2>/dev/null
}

configure_port_forwarding() {
    kubectl port-forward --namespace $NAMESPACE postgresql-0 5432:5432 &
}

wait_for_database_ready() {
    until [ "$(get_database_status)" == "Running" ]
    do
        info_progress "...";
        sleep 3;
    done
    info_message "database started successfully";
}

#configure_postgres() {
#    pushd $kube_dir/pgadmin
#    install_pgadmin;
#    popd
#}

get_database_service() {
    echo $POSTGRESQL_HOST
}

get_database_port() {
    echo $POSTGRESQL_PORT
}

