#!/bin/bash

source "./env.sh"
source "$kube_dir/cluster/cluster.sh"
source "$kube_dir/cluster/kubernetes.sh"
source "$kube_dir/database/database.sh"

echo "----------------"
echo "Current Cluster: $KUBE_CLUSTER_NAME"
echo "----------------"

if [[ $# -eq 0 ]]; then  
  echo "Parameters:"
  echo "==========="
  echo " - on      : start $PRODUCT cluster"
  echo " - off     : stop $PRODUCT cluster"
  echo " - pgport  : Open postgres port $POSTGRESQL_PORT if active"
  echo " - imgls   : list images from $KUBE_SOURCE_REGISTRY (var KUBE_IMAGES in env.sh)"
  echo " - imgpull : pull images from $KUBE_SOURCE_REGISTRY (var KUBE_IMAGES in env.sh)"
  echo " - list    : list clusters"
  echo " - create  : create $PRODUCT cluster"  
  echo " - remove  : remove $PRODUCT cluster"
  echo " - debug   : generate outputs for get/describe of each kubernetes resources"
 
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

    elif [[ $option == "pgport" ]]; then

         if get_database_status; then
            # cluster/cluster.sh
            sudo ufw allow 5432
            configure_port_forwarding;
         else
            echo "$POSTGRESQL_PORT is not active"
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
         
         registry_name=k3d-$KUBE_LOCALREGISTRY_NAME

         if exist_cluster; then
            # cluster/cluster.sh
            remove_cluster;
         else
            echo "$KUBE_CLUSTER_NAME cluster doesn't exist" 
            if k3d registry list | grep $registry_name >/dev/null; then
               echo "Deleting existing registry $registry_name"
               k3d registry delete $registry_name
            fi   
         fi

    elif [[ $option == "debug" ]]; then
         
         if isactive_cluster; then
            # cluster/cluster.sh
            debug_cluster;
         else
            echo "$KUBE_CLUSTER_NAME cluster is not active"            
         fi  
         
    else    
      echo "($option) is not valid."
    fi
  done
fi