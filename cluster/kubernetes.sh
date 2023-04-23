#!/bin/bash

install_docker_compose() {
    info_message "Installing docker_compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

install_k3d() {
    info_message "Installing k3d..."
    curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=v5.4.6 bash
}

install_kubectl() {
    info_message "Installing kubectl..."
    curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.22.17/2023-01-30/bin/linux/amd64/kubectl
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/kubectl
}

install_helm() {
    info_message "Installing helm..."
    export DESIRED_VERSION=v3.8.2
    curl -s https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
}

install_terraform() {
    info_message "Installing terraform..."
    sudo apt install -y gnupg software-properties-common curl
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt update && sudo apt install terraform
}

is_wsl() {
  case "$(uname -r)" in
  *microsoft* ) true ;; # WSL 2
  *Microsoft* ) true ;; # WSL 1
  * ) false;;
  esac
}

install_docker(){
  if is_wsl; then
    #Update Ubuntu distro
    sudo apt-get -y update
    sudo apt-get -y upgrade
    #Install docker
    sudo apt-get -y install containerd docker.io
    #Call visudo
    printf "\n# Docker daemon specification\n%s ALL=(ALL) NOPASSWD: /usr/bin/dockerd\n" $USER | sudo EDITOR='tee -a' visudo
    #Modify bash settings
    printf "\n# Start Docker daemon automatically when logging in if not running.\nRUNNING=\`ps aux | grep dockerd | grep -v grep\`\nif [ -z \"\$RUNNING\" ]; then\n    sudo dockerd > /dev/null 2>&1 &\n    disown\nfi\n" >> ~/.bashrc
    #Add user to docker group
    sudo usermod -aG docker $USER
    echo -e "\nIn 10 seconds this WSL session will be closed. Then reopen a new WSL session to continue..."
    sleep 10; kill -9 $PPID
  else
    curl -fsSL https://get.docker.com | bash
    #Enable docker service
    sudo systemctl enable docker.service
    sudo systemctl start docker.service
    #Add user to docker group
    sudo usermod -aG docker $USER
    sudo chmod 666 /var/run/docker.sock
  fi
}