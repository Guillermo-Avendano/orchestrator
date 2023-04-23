#!/bin/bash

source "$kube_dir/cluster/local_registry.sh"
source "$kube_dir/common/common.sh"

create_cluster(){
    info_message "Creating registry $KUBE_LOCALREGISTRY_NAME"

    registry_name=k3d-$KUBE_LOCALREGISTRY_NAME
    if k3d registry list | grep $registry_name >/dev/null; then
        echo "Deleting existing registry $registry_name"
        k3d registry delete $registry_name
    fi   
    k3d registry create $KUBE_LOCALREGISTRY_NAME --port 0.0.0.0:${KUBE_LOCALREGISTRY_PORT}

    info_message "Creating $KUBE_CLUSTER_NAME cluster..."

    KUBE_CLUSTER_REGISTRY="--registry-use k3d-$KUBE_LOCALREGISTRY_NAME:5000 --registry-config $kube_dir/cluster/registries.yaml"

    k3d cluster create $KUBE_CLUSTER_NAME -p "80:80@loadbalancer" -p "$NGINX_EXTERNAL_TLS_PORT:443@loadbalancer" --agents 2 --k3s-arg "--disable=traefik@server:0" $KUBE_CLUSTER_REGISTRY
    
    #k3d kubeconfig get $KUBE_CLUSTER_NAME > $kube_dir/cluster/cluster-config.yaml

    kubectl config use-context k3d-$KUBE_CLUSTER_NAME
    
    # Getting Images
    # "$kube_dir/cluster/local_registry.sh"
    push_images_to_local_registry;

    # Install ingress
    kubectl create namespace ingress-nginx
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.3/deploy/static/provider/cloud/deploy.yaml -n ingress-nginx
}

remove_cluster() {
    info_message "Removing $KUBE_CLUSTER_NAME cluster..."
    k3d cluster delete $KUBE_CLUSTER_NAME

    registry_name=k3d-$KUBE_LOCALREGISTRY_NAME
    if k3d registry list | grep $registry_name >/dev/null; then
        echo "Deleting existing registry $registry_name"
        k3d registry delete $registry_name
    fi  
    k3d registry delete $KUBE_LOCALREGISTRY_NAME    
    docker network rm k3d-$KUBE_CLUSTER_NAME
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

    namespace_list=(${TF_VAR_NAMESPACE} ${TF_VAR_NAMESPACE_SHARED})
    # namespace_list=( ${TF_VAR_NAMESPACE} )

    for namespace in "${namespace_list[@]}"
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