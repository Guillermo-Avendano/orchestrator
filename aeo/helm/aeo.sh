
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

    helm upgrade -f $AEO_VALUES aeo-$NAMESPACE helm/aeo-4.3.1 --namespace $NAMESPACE --install;
}

uninstall_aeo(){
    helm uninstall aeo-$NAMESPACE --namespace $NAMESPACE
}
