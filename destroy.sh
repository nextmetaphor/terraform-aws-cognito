#!/usr/bin/env bash

rm terraform.tfstate*
rm tfplan
rm .terraform.lock.hcl

terraform init