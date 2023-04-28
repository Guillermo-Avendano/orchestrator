# AEO 4.3.1.x

## Introduction

- Enterprise Orchestrator 4.3.1.x - k3d installation

## Prerequisites

- Ubuntu-WSL / Ubuntu 20.04 or higher
- 16 GB / 4 CPUs
- Ubuntu WSL Installation: https://learn.microsoft.com/en-us/windows/wsl/install-manual

## Preinstallation actions
### Ubuntu: get installations scripts
```bash
git clone https://github.com/guillermo-avendano/orchestrator.git
cd orchestrator
```
### Define variable DOCKER_PASSWORD in "$HOME/.profile" for pulling imags from "registry.rocketsoftware.com"
- Encrypt password
```bash
echo "RCC password" | base64
```
- Edit "$HOME/.profile" (nano $HOME/.profile), and define the variable DOCKER_PASWORD with the output of previous "echo"
```bash
export DOCKER_PASSWORD="[RCC password encripted base64]"
```
### Edit ./env.sh (nano ./env.sh), and update variable DOCKER_USER in
```bash
DOCKER_USER="<RCC user>@rs.com"
```
### Optional: add these lines to "$HOME/.profile" for facilitate the commnads' typing
```bash
alias k="kubectl"
alias ta="terraform apply"
alias ti="terraform init"
```
### Update environment variables
```bash
source $HOME/.profile
source ./env.sh
```
### Check versions for scheduler, clientmgr, and agent
```bash
./rockcluster.sh imgls
```
### Variables in "./env.sh", update image versions if needed:
```bash
IMAGE_SCHEDULER_NAME=aeo/scheduler
IMAGE_SCHEDULER_VERSION=4.3.1.61
IMAGE_CLIENTMGR_NAME=aeo/clientmgr
IMAGE_CLIENTMGR_VERSION=4.3.1.61
IMAGE_AGENT_NAME=aeo/agent
IMAGE_AGENT_VERSION=4.3.1.58
AEO_URL = "aeo.rocketsoftware.com"
```

###  Add AEO_URL to /etc/hosts, or c:/windows/system32/drivers/etc/hosts with the IP where the custer is running, example:
```bash
192.168.0.5     aeo.rocketsoftware.com
```
## Installation sequence

1; Pre-requisites
- Install dos2unix
```bash
sudo apt install -y dos2unix
```
- Change file formats
```bash
find . -name "*.yaml" -exec dos2unix {} \;
find . -name "*.sh" -exec dos2unix {} \;
```
- Enable scripts for execution
```bash
chmod -R u+x *.sh
```

2; set environment
```bash
source env.sh
```
3; Install docker, k3d, helm, kubectl and terraform
```bash
./pre-reqs-install.sh
```
4; Verify docker (more information https://docs.docker.com/desktop/install/ubuntu/)
```bash
docker version
```
5; Create the cluster for aeo, and pull images from registry.rocketsoftware.com
```bash
./rockcluster.sh create
```
6; Install database, scheduler, clientmgr, and agent
```bash
cd aeo
./install.sh
```
6; Enterprise Orchestrator URL: http://aeo.rocketsoftware.com/aeo
- user: aeo
- password: aeo

## Summary of commands (under "orchestrator" directory)

| Command | Description |
|:---|:---|
| ./rockcluster.sh on | start aeo cluster |
| ./rockcluster.sh off | stop aeo cluster |
| ./rockcluster.sh pgport | Open postgres port if active for remote access from SQL tools |
| ./rockcluster.sh imgls | list images from registry.rocketsoftware.com |
| ./rockcluster.sh imgpull | pull images from registry.rocketsoftware.com |
| ./rockcluster.sh list | list clusters |
| ./rockcluster.sh create | create aeo cluster |
| ./rockcluster.sh remove | remove aeo cluster |
| ./rockcluster.sh debug | generate outputs for get/describe for kubernetes resources  |

### Install aeo components (under "orchestrator" directory)

- cd aeo
- ./install.sh

### Remove components with the namespece associated. (under "orchestrator" directory)

- cd aeo
- ./remove.sh
