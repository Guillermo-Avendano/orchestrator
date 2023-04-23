#!/bin/bash

command_exists() {
	[ -x "$1" ] || command -v $1 >/dev/null 2>/dev/null
}

replace_tag_in_file() {
    local filename=$1
    local search=$2
    local replace=$3

    if [[ $search != "" ]]; then
        # Escape not allowed characters in sed tool
        search=$(printf '%s\n' "$search" | sed -e 's/[]\/$*.^[]/\\&/g');
        replace=$(printf '%s\n' "$replace" | sed -e 's/[]\/$*.^[]/\\&/g');
        sed -i'' -e "s/$search/$replace/g" $filename
    fi
}

highlight_message() {
    local yellow=`tput setaf 3`
    local reset=`tput sgr0`

    echo -e "\r"
    echo "${yellow}********************************************${reset}"
    echo "${yellow}**${reset} $1 "
    echo "${yellow}********************************************${reset}"
}

info_message() {
    local yellow=`tput setaf 3`
    local reset=`tput sgr0`

    echo -e "\r"
    echo "${yellow}>>>>>${reset} $1"
}

error_message() {
    local yellow=`tput setaf 3`
    local red=`tput setaf 1`
    local reset=`tput sgr0`

    echo -e "\r"
    echo "${yellow}>>>>>${reset} ${red} Error: $1${reset}"
}

info_progress_header() {
    local yellow=`tput setaf 3`
    local reset=`tput sgr0`

    echo -e "\r"
    echo -n "${yellow}>>>>>${reset} $1"
}

info_progress() {
    echo -n "$1"
}

detect_os() {
    case "$(awk -F'=' '/^ID=/ { gsub("\"","",$2); print tolower($2) }' /etc/*-release 2> /dev/null)" in
      *debian*)    OS="debian";; # WSL2
      *ubuntu*)    OS="debian";;
      *rhel*)      OS="rhel";;   # Red Hat
      *centos*)    OS="centos";;
      Darwin*)     OS="darwin";;
      *)           OS="UNKNOWN"
    esac
}	

ask_binary_question() {
    # $1 is the question that will be diplayed.
    # $2 if the quiet mode value (true or false)
    local answer="Y"

    if [ "$2" == "false" ]; then
        while true; do
            read -p "$1 " yn
            case $yn in
                [Yy]* ) answer="Y"; break;;
                [Nn]* ) answer="N"; break;;
                * );;
            esac
        done
    fi
    echo "$answer"
}

kube_init(){
    KUBE_EXE="k3d"
    KUBE_CLI_EXE="kubectl"
    CONTAINER_EXE="docker"    
}