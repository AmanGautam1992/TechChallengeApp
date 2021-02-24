variable "namerg" {
  type    = string
}
variable "locationrg" {
  type    = string
}
variable "pgsqlservername" {
  type    = string
}
variable "pgsqldbname" {
  type    = string
}
variable "pgsqldbfwrule" {
  type    = string
}
variable "cluster_name" {
  type        = string
  description = "AKS name in Azure"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
}

variable "system_node_count" {
  type        = number
  description = "Number of AKS worker nodes"
}

variable "acr_name" {
  type        = string
  description = "ACR name"
}

variable "psql_admin_username" {
  type        = string
  description = "psql admin username"
}

variable "psql_admin_password" {
  type        = string
  description = "psql admin password"
}
