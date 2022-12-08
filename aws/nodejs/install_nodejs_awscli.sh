#!/bin/bash

# Get VPC ID of the default vpc
VPC_ID=`aws ec2 describe-vpcs | jq '.Vpcs[] | select(.IsDefault==true).VpcId' | tr \" \ `
echo $VPC_ID

# Create a security group in the default vpc
aws ec2 create-security-group --group-name node-sg --description "NodeJS Security Group" --vpc-id $VPC_ID
SG_ID=`aws ec2 describe-security-groups | jq '.SecurityGroups[] |select(.GroupName=="node-sg").GroupId'|tr \" \ `
echo $SG_ID

# Add ingress rule to security group
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 3000 \
    --cidr 0.0.0.0/0

# Get Ubuntu Image AMI_ID
AMI_ID=`aws ec2 describe-images --filters "Name=name,Values=ubuntu-minimal/images/hvm-ssd/ubuntu-jammy-22.04-amd64-minimal-20220810" "Name=root-device-type,Values=ebs"|jq '.Images[0].ImageId' | tr \" \ `

# Launch The Instance
aws ec2 run-instances --image-id $AMI_ID --count 1 --instance-type t2.micro  --security-group-ids $SG_ID --user-data file://./user-data.sh
