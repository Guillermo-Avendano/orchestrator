# AEO 4.3.1.x

## Introduction

- Enterprise Orchestrator 4.3.1.x - k3d installation

## Prerequisites

- Ubuntu-WSL / Ubuntu 20.04 or higher
- 16 GB / 4 CPUs

## Preinstallation actions
### Define the environment variable DOCKER_PASSWORD in "$HOME/.profile"
```bash
echo "RCC password" | base64
export DOCKER_PASSWORD=[RCC password encripted base64]
```
### Optional: add these lines to "$HOME/.profile" for facilitate the commnads' typing
```bash
alias k="kubectl"
alias ta="terraform apply"
alias ti="terraform init"
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

###  in "./env.sh", and add these values to /etc/hosts c:/windows/system32/drivers/etc/hosts with the IP where the custer will run, example:
```bash
192.168.0.5     aeo.rocketsoftware.com
```
## Installation sequence

1; Pre-requisites
```bash
sudo apt install -y dos2unix
find . -name "*.yaml" -exec dos2unix {} \;
find . -name "*.sh" -exec dos2unix {} \;
chmod -R u+x *.sh
```

2; set environment
- source env.sh

3; Install docker, k3d, helm, kubectl and terraform
- ./pre-reqs-install.sh

4; Create the cluster for aeo, and pull images from registry.rocketsoftware.com
- ./rockcluster.sh create

5; Install database, scheduler, clientmgr, and agent
- cd aeo
- ./install.sh

## Summary of commands

| Command | Description |
|:---|:---|
| rockcluster.sh on | start aeo cluster |
| rockcluster.sh off | stop aeo cluster |
| rockcluster.sh pgport | Open postgres port if active for remote access from other tools |
| rockcluster.sh imgls | list images from registry.rocketsoftware.com |
| rockcluster.sh imgpull | pull images from registry.rocketsoftware.com |
| rockcluster.sh list | list clusters |
| rockcluster.sh create | create aeo cluster |
| rockcluster.sh remove | remove aeo cluster |
| rockcluster.sh debug | generate outputs for get/describe of each kubernetes resources  |

### Install of aeo components

- cd aeo
- ./install.sh

### Remove aeo components with the namespece associated.

- cd aeo
- ./remove.sh
