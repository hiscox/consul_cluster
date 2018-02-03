variable "location" {
  type        = "string"
  description = "Azure region to deploy to"
}

variable "application" {
  type        = "string"
  description = "Name of the application that will use this cluster"
}

variable "environment" {
  type        = "string"
  description = "Name of the environment the cluster belongs to"
}

variable "name_prefix" {
  type        = "string"
  description = "4 character prefix for resource names"
}

variable "consul_version" {
  default     = "1.0.3"
  description = "Version of consul to deploy"
}

variable "vnet_resource_group_name" {}
variable "vnet_name" {}
variable "subnet_name" {}

variable "vm_count" {
  default = 3
}

variable "tags" {
  type    = "map"
  default = {}
}
