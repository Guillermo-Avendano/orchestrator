# The content is replaced by the env variable TF_VAR_NAMESPACE in ./common/env.sh if exists
variable "NAMESPACE" { default = "rocket" }
variable "kube_config" { default = "../cluster/.cluster-config.yaml"}

variable "KUBE_LOCALREGISTRY_HOST" { default = "localhost"}
variable "KUBE_LOCALREGISTRY_PORT" { default = "5000"}

# AEO
variable "IMAGE_SCHEDULER_NAME" { default = "aeo/scheduler"}
variable "IMAGE_SCHEDULER_VERSION" { default = "4.3.1.61"}
variable "IMAGE_CLIENTMRG_NAME" { default = "aeo/clientmgr"}
variable "IMAGE_CLIENTMRG_VERSION" { default = "4.3.1.61"}
variable "IMAGE_AGENT_NAME" { default = "aeo/agent"}
variable "IMAGE_AGENT_VERSION" { default = "4.3.1.58"}

variable "POSTGRESQL_USERNAME" { default = "mobius"}
variable "POSTGRESQL_PASSWORD" { default = "password"}
variable "POSTGRESQL_PASSENCR" { default = "3X6ApGn/D3cgkTxc730BGhvV6C6A6YPfGare9QjWgdT5rkI9wCWWFRvfYk1f5PXqN"}
variable "POSTGRESQL_DBNAME" { default = "aeo"}
variable "POSTGRESQL_HOST" { default = "postgresql.shared.svc.cluster.local"}
variable "POSTGRESQL_PORT" { default = "5432"}