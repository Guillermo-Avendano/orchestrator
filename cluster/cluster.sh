#!/bin/bash

source "$kube_dir/cluster/local_registry.sh"
source "$kube_dir/common/common.sh"

gen_registry_yaml(){
  echo  "mirrors:" > $kube_dir/cluster/registry.yaml
  echo  "  \"$KUBE_LOCALREGISTRY_HOST:$KUBE_LOCALREGISTRY_PORT\":"  >> $kube_dir/cluster/registry.yaml
  echo  "    endpoint:"        >> $kube_dir/cluster/registry.yaml
  echo  "      - http://k3d-$KUBE_LOCALREGISTRY_NAME:$KUBE_LOCALREGISTRY_PORT"   >> $kube_dir/cluster/registry.yaml
}
					  
create_cluster(){

    info_message "Creating registry $KUBE_LOCALREGISTRY_NAME"
    registry_name=k3d-$KUBE_LOCALREGISTRY_NAME
    if k3d registry list | grep $registry_name >/dev/null; then
        echo "Deleting existing registry $registry_name"
        k3d registry delete $registry_name
    fi   
    k3d registry create $KUBE_LOCALREGISTRY_NAME --port 0.0.0.0:${KUBE_LOCALREGISTRY_PORT}

    info_message "Creating $KUBE_CLUSTER_NAME cluster..."
    
    #DO NOT WORK: gen_registry_yaml;

    KUBE_CLUSTER_REGISTRY="--registry-use k3d-$KUBE_LOCALREGISTRY_NAME:$KUBE_LOCALREGISTRY_PORT --registry-config $kube_dir/cluster/registries.yaml"

    k3d cluster create $KUBE_CLUSTER_NAME -p "80:80@loadbalancer" -p "30779:30779@loadbalancer" -p "$NGINX_EXTERNAL_TLS_PORT:443@loadbalancer" --agents 2 --k3s-arg "--disable=traefik@server:0" $KUBE_CLUSTER_REGISTRY
    
    #DO NOT WORK: k3d cluster create --config $kube_dir/cluster/cluster-configuration.yaml

    kubectl config use-context k3d-$KUBE_CLUSTER_NAME
    
    # Getting Images
    # "$kube_dir/cluster/local_registry.sh"
    if [[ "$KUBE_IMAGE_PULL" == "YES" ]]; then
        push_images_to_local_registry;
    fi

    # Install ingress
    kubectl create namespace ingress-nginx
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.3/deploy/static/provider/cloud/deploy.yaml -n ingress-nginx
    
    # V2: kubectl apply -f $kube_dir/cluster/nginx-ingress-controller.yaml -n kube-system

    info_progress_header "Verifying $KUBE_CLUSTER_NAME cluster..."

    POD_NAMES=("ingress-nginx-controller")
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
        # V2: while [[ $(kubectl -n kube-system pods | grep $POD_NAME | awk '{print $3}') != "Runnng" ]]
        while [[ $(kubectl -n ingress-nginx get pods | grep $POD_NAME | awk '{print $3}') != "Running" ]]    
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

    helm upgrade --create-namespace -i -n portainer portainer portainer/portainer

    highlight_message "$KUBE_CLUSTER_NAME cluster started !"						  
}

remove_cluster() {
    info_message "Removing $KUBE_CLUSTER_NAME cluster..."
    k3d cluster delete $KUBE_CLUSTER_NAME

    registry_name=k3d-$KUBE_LOCALREGISTRY_NAME
    if k3d registry list | grep $registry_name >/dev/null; then
        echo "Deleting existing registry $registry_name"
        k3d registry delete $registry_name
    fi  
}

start_cluster() {
    info_message "Starting $KUBE_CLUSTER_NAME cluster..."
    k3d cluster start $KUBE_CLUSTER_NAME 
    kubectl config use-context k3d-$KUBE_CLUSTER_NAME    
}

stop_cluster() {
    info_message "Stopping $KUBE_CLUSTER_NAME cluster"
    k3d cluster stop $KUBE_CLUSTER_NAME
}

list_cluster() {
    info_message "Cluster's list"
    k3d cluster list
}

isactive_cluster() {

    local cluster_status=$(k3d cluster list | grep "$KUBE_CLUSTER_NAME" | awk '{print $2}')
    
    if [[ "$cluster_status" == "1/1" ]]; then
        # Active
        return 0
    elif [[ -n "$cluster_status" ]]; then
        # Not active
        return 1
    else
        # Not exists
        return 1
    fi
}

exist_cluster() {

    local cluster_status=$(k3d cluster list | grep "$KUBE_CLUSTER_NAME" | awk '{print $2}')
    
    if [[ "$cluster_status" == "1/1" ]]; then
        # Active
        return 0
    elif [[ -n "$cluster_status" ]]; then
        # Not active
        return 0
    else
        # Not exists
        return 1
    fi
}

debug_cluster(){
    log_dir="logs"

    if [ ! -d "$log_dir" ]; then
       mkdir -p "$log_dir"
    else
       rm $log_dir/*.*
    fi

    for namespace in "${KUBE_NS_LIST[@]}"
        do
            echo "Namespace: $namespace"

            pods=$(kubectl -n $namespace get pods --output=name)

            for pod in $pods
                do
                pod_name=$(echo $pod | cut -d/ -f2) 
                kubectl -n $namespace get pod/$pod_name -o yaml > $log_dir/${namespace}_${pod_name}_POD_GET.yaml 
                kubectl -n $namespace describe pod/$pod_name    > $log_dir/${namespace}_${pod_name}_POD_DESCRIBE.txt
                kubectl -n $namespace logs pod/$pod_name        > $log_dir/${namespace}_${pod_name}_POD_LOG.txt

                done

            services=$(kubectl -n $namespace get services --output=name)

            for srv in $services
                do
                srv_name=$(echo $srv | cut -d/ -f2) 

                kubectl -n $namespace get service/$srv_name -o yaml > $log_dir/${namespace}_${srv_name}_SERVICE_GET.yaml 
                kubectl -n $namespace describe service/$srv_name    > $log_dir/${namespace}_${srv_name}_SERVICE_DESCRIBE.txt

                done

            ingresses=$(kubectl -n $namespace get ingress --output=name)

            for ingress in $ingresses
                do
                ingress_name=$(echo $ingress | cut -d/ -f2) 

                kubectl -n $namespace get ingress/$ingress_name -o yaml > $log_dir/${namespace}_${ingress_name}_INGRESS_GET.yaml 
                kubectl -n $namespace describe ingress/$ingress_name    > $log_dir/${namespace}_${ingress_name}_INGRESS_DESCRIBE.txt

                done

            secrets=$(kubectl -n $namespace get secret --output=name)

            for secret in $secrets
                do
                secret_name=$(echo $secret | cut -d/ -f2) 

                if [[ ! "$secret_name" == *".helm."* ]]; then
                    kubectl -n $namespace get secret/$secret_name -o yaml > $log_dir/${namespace}_${secret_name}_SECRET_GET.yaml 
                    #kubectl -n $namespace describe secret/$secret_name    > $log_dir/${namespace}_${secret_name}_DESCRIBE_SECRET.txt
                fi
                done

            echo "Debug files in ./$log_dir"
        done
}


create_folders() {
    info_message "Creating volumes..."
    #set up volumes CLIENTMGR
    PVC-AEO-CLIENTMGR=`eval echo ~/${NAMESPACE}_data/PV-AEO-CLIENTMGR`
    if [ ! -d $PVC-AEO-CLIENTMGR]; then
        mkdir -p $PVC-AEO-CLIENTMGR;
        chmod -R 777 $PVC-AEO-CLIENTMGR;  
    fi
    PVC-AEO-CLIENTMGR-CTL-LOG=`eval echo ~/${NAMESPACE}_data/PV-AEO-CLIENTMGR-CTL-LOG`
    if [ ! -d $PVC-AEO-CLIENTMGR-CTL-LOG]; then
        mkdir -p $PVC-AEO-CLIENTMGR-CTL-LOG;
        chmod -R 777 $PVC-AEO-CLIENTMGR-CTL-LOG;  
    fi
    #set up volumes SCHEDULER
    PVC-AEO-SCHEDULER=`eval echo ~/${NAMESPACE}_data/PV-AEO-SCHEDULER`
    if [ ! -d $PVC-AEO-SCHEDULER]; then
        mkdir -p $PVC-AEO-SCHEDULER;
        chmod -R 777 $PVC-AEO-SCHEDULER;  
    fi
    PVC-AEO-SCHEDULER-CTL-LOG=`eval echo ~/${NAMESPACE}_data/PV-AEO-SCHEDULER-CTL-LOG`
    if [ ! -d $PVC-AEO-SCHEDULER-CTL-LOG]; then
        mkdir -p $PVC-AEO-SCHEDULER-CTL-LOG;
        chmod -R 777 $PVC-AEO-SCHEDULER-CTL-LOG;  
    fi
    #set up volumes AGENT
    PVC-AEO-AGENT=`eval echo ~/${NAMESPACE}_data/PV-AEO-AGENT`
    if [ ! -d $PVC-AEO-AGENT]; then
        mkdir -p $PVC-AEO-AGENT;
        chmod -R 777 $PVC-AEO-AGENT;  
    fi
    PVC-AEO-AGENT-CTL-LOG=`eval echo ~/${NAMESPACE}_data/PV-AEO-AGENT-CTL-LOG`
    if [ ! -d $PVC-AEO-AGENT-CTL-LOG]; then
        mkdir -p $PVC-AEO-AGENT-CTL-LOG;
        chmod -R 777 $PVC-AEO-AGENT-CTL-LOG;  
    fi
    PVC-AEO-AGENT-SERVICES=`eval echo ~/${NAMESPACE}_data/PV-AEO-AGENT-SERVICES`
    if [ ! -d $PVC-AEO-AGENT-SERVICES]; then
        mkdir -p $PVC-AEO-AGENT-SERVICES;
        chmod -R 777 $PVC-AEO-AGENT-SERVICES;  
    fi

    COMMON_VOLUME=`eval echo ~/${NAMESPACE}_data/common`
    if [ ! -d $COMMON_VOLUME ]; then
        mkdir -p $COMMON_VOLUME;
        chmod -R 777 $COMMON_VOLUME;
    fi

    #set env
    # extra args can be used to add other volume mounts or other arguments
    VOLUME_MAPPING="--volume ${PVC-AEO-CLIENTMGR}:${PVC-AEO-CLIENTMGR} --volume ${PVC-AEO-CLIENTMGR-CTL-LOG}:${PVC-AEO-CLIENTMGR-CTL-LOG} --volume ${PVC-AEO-SCHEDULER}:${PVC-AEO-SCHEDULER} --volume ${PVC-AEO-SCHEDULER-CTL-LOG}:${PVC-AEO-SCHEDULER-CTL-LOG} --volume ${PVC-AEO-AGENT}:${PVC-AEO-AGENT} --volume ${PVC-AEO-AGENT-CTL-LOG}:${PVC-AEO-AGENT-CTL-LOG} --volume ${PVC-AEO-AGENT-SERVICES}:${PVC-AEO-AGENT-SERVICES} --volume  $COMMON_VOLUME:/var/lib/rancher/k3s/storage@all"

}