#!/usr/bin/env bash

# cleans old terraform files and re-initialises the provider
rm terraform.tfstate*
rm tfplan
rm .terraform.lock.hcl

terraform init