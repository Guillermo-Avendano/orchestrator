#!/bin/bash

source "./env.sh"
source "$kube_dir/cluster/cluster.sh"
source "$kube_dir/cluster/kubernetes.sh"

if [[ $# -eq 0 ]]; then
  echo "Parameters:"
  echo "==========="
  echo " - on      : start $PRODUCT cluster"
  echo " - off     : stop $PRODUCT cluster"
  echo " - imgls   : list images from $KUBE_SOURCE_REGISTRY (var KUBE_IMAGES in env.sh)"
  echo " - imgpull : pull images from $KUBE_SOURCE_REGISTRY (var KUBE_IMAGES in env.sh)"
  echo " - list    : list clusters"
  echo " - create  : create $PRODUCT cluster"  
  echo " - remove  : remove $PRODUCT cluster"
  echo " - debug   : generate outputs for get/describe of each kubernetes resources"
  echo " - install : install k3d, helm, kubectl and terraform"
else
  for option in "$@"; do
    if [[ $option == "on" ]]; then

         if ! exist_cluster; then
            echo "$KUBE_CLUSTER_NAME cluster doesn't exist"
         elif isactive_cluster; then
            echo "$KUBE_CLUSTER_NAME cluster is active"
         else
            # cluster/cluster.sh
            start_cluster;
         fi

    elif [[ $option == "off" ]]; then

         if isactive_cluster; then
            # cluster/cluster.sh
            stop_cluster;
         else
            echo "$KUBE_CLUSTER_NAME cluster is not active"
         fi

    elif [[ $option == "imgls" ]]; then
         # cluster/local_registry.sh
         list_images;

    elif [[ $option == "imgpull" ]]; then
         
         if isactive_cluster; then
            # cluster/local_registry.sh
            push_images_to_local_registry; 
         else
            echo "$KUBE_CLUSTER_NAME cluster is not active"
         fi   

    elif [[ $option == "list" ]]; then
         # cluster/cluster.sh
         list_cluster;

    elif [[ $option == "create" ]]; then
         
         if isactive_cluster; then
            echo "$KUBE_CLUSTER_NAME cluster is active"
         else    
            # cluster/cluster.sh
            create_cluster;
         fi

    elif [[ $option == "remove" ]]; then
         
         if exist_cluster; then
            # cluster/cluster.sh
            remove_cluster;
         else
            echo "$KUBE_CLUSTER_NAME cluster doesn't exist"            
         fi

    elif [[ $option == "debug" ]]; then
         
         if isactive_cluster; then
            # cluster/cluster.sh
            debug_cluster;
         else
            echo "$KUBE_CLUSTER_NAME cluster is not active"            
         fi  
         
    elif [[ $option == "install" ]]; then
         
         if ! docker --version  >/dev/null 2>&1; then
            # cluster/kubernetes.sh
            install_docker;
         fi

         if ! docker-compose --version  >/dev/null 2>&1; then
            # cluster/kubernetes.sh
            install_docker_compose;
         fi

         if ! k3d --version >/dev/null 2>&1; then
            # cluster/kubernetes.sh
            install_k3d;
         fi

         if ! kubectl version >/dev/null 2>&1; then
            # cluster/kubernetes.sh
            install_kubectl;
         fi

         if helm version  >/dev/null 2>&1; then
            # cluster//kubernetes.sh
            install_helm;
         fi

         if ! terraform -version  >/dev/null 2>&1; then
            # cluster/kubernetes.sh
            install_terraform;
         fi
    else    
      echo "($option) is not valid."
    fi
  done
fi