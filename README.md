# README #

### What is this repository for? ###

* Terraform module to deploy a Consul cluster in Azure

### About this module ###

* This module will deploy CoreOS hosts with a Consul server running
in a Docker container on each host

* An encryption key will be generated for the gossip protocol and output

### How do I deploy? ###

All configuration is done using CoreOS Ignition scripts so no
connectivity to the hosts is required

* terraform init
* terraform apply