#!/bin/bash

/opt/packer plugins install github.com/hashicorp/amazon
/opt/packer plugins install github.com/hashicorp/ansible
TEST=`/opt/packer build template.json | tail -2`
AMI_ID=`echo $TEST|cut -d ":" -f2`
echo $AMI_ID
echo 'variable "AMI_ID" { default = "'${AMI_ID//[[:blank:]]/}'"  }' > newvariable.tf
terraform init
terraform apply -auto-approve
