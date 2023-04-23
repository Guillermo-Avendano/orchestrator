#!/bin/bash

source "$kube_dir/common/common.sh"

login_docker(){
    docker login --username ${DOCKER_USER} --password ${DOCKER_PASS} ${KUBE_SOURCE_REGISTRY}
}

pull_images(){
    local registry_src=${KUBE_SOURCE_REGISTRY}

    for image in "${KUBE_IMAGES[@]}" 
        do
            IFS=':' read -ra kv <<< "$image"
            image_name="${kv[0]}"
            image_tag="${kv[1]}"
            docker pull ${registry_src}/${image_name}:${image_tag} 
        done
}

tag_images(){
    local registry_src=${KUBE_SOURCE_REGISTRY}
    local registry_target=${KUBE_LOCALREGISTRY_HOST}:${KUBE_LOCALREGISTRY_PORT}

    for image in "${KUBE_IMAGES[@]}" 
        do
            IFS=':' read -ra kv <<< "$image"
            image_name="${kv[0]}"
            image_tag="${kv[1]}"
            docker tag ${registry_src}/${image_name}:${image_tag} ${registry_target}/${image_name}:${image_tag}
        done
}

list_images(){
    info_message "images from $KUBE_SOURCE_REGISTRY"
    for image in "${KUBE_IMAGES[@]}" 
        do
            IFS=':' read -ra kv <<< "$image"
            image_name="${kv[0]}"
            image_tag="${kv[1]}"
            curl -X GET -u $DOCKER_USER:$DOCKER_PASS https://registry.rocketsoftware.com/v2/$image_name/tags/list
            echo ""
        done     
}

push_images(){
 
    local registry_target=${KUBE_LOCALREGISTRY_HOST}:${KUBE_LOCALREGISTRY_PORT}

    docker login  --username ${DOCKER_USER} --password ${DOCKER_PASS} $registry_target

    for image in "${KUBE_IMAGES[@]}" 
        do
            IFS=':' read -ra kv <<< "$image"
            image_name="${kv[0]}"
            image_tag="${kv[1]}"
            docker push ${registry_target}/${image_name}:${image_tag}
        done
}

push_images_to_local_registry(){

    info_message "Login remote registry"
    login_docker;

    info_message "Pull images"
    pull_images;

    info_message "Tag images"
    tag_images;

    info_message "Push images"
    push_images;

}


