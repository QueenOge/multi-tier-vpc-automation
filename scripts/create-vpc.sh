#!/bin/bash

# AWS CLI profile and region
PROFILE="queenoge"
REGION="us-east-1"

# VPC configuration
VPC_CIDR="10.0.0.0/16"
WEB_SUBNET_CIDR="10.0.1.0/24"
APP_SUBNET_CIDR="10.0.2.0/24"
DB_SUBNET_CIDR="10.0.3.0/24"

AZ1="us-east-1a"
AZ2="us-east-1b"
AZ3="us-east-1c"

# Create VPC
echo "Creating VPC..."
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block $VPC_CIDR \
  --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=QueenOge-VPC}]" \
  --query 'Vpc.VpcId' --output text \
  --region $REGION --profile $PROFILE)

echo "VPC Created: $VPC_ID"

# Create Subnets
echo "Creating Subnets..."
WEB_SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $WEB_SUBNET_CIDR \
  --availability-zone $AZ1 \
  --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=QueenOge-Web-Subnet}]" \
  --query 'Subnet.SubnetId' --output text \
  --region $REGION --profile $PROFILE)

APP_SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $APP_SUBNET_CIDR \
  --availability-zone $AZ2 \
  --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=QueenOge-App-Subnet}]" \
  --query 'Subnet.SubnetId' --output text \
  --region $REGION --profile $PROFILE)

DB_SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $DB_SUBNET_CIDR \
  --availability-zone $AZ3 \
  --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=QueenOge-DB-Subnet}]" \
  --query 'Subnet.SubnetId' --output text \
  --region $REGION --profile $PROFILE)

echo "Subnets Created:"
echo "  Web: $WEB_SUBNET_ID"
echo "  App: $APP_SUBNET_ID"
echo "  DB:  $DB_SUBNET_ID"

# Create and Attach Internet Gateway
echo "Creating Internet Gateway..."
IGW_ID=$(aws ec2 create-internet-gateway \
  --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Name,Value=QueenOge-IGW}]" \
  --query 'InternetGateway.InternetGatewayId' --output text \
  --region $REGION --profile $PROFILE)

aws ec2 attach-internet-gateway \
  --internet-gateway-id $IGW_ID \
  --vpc-id $VPC_ID \
  --region $REGION --profile $PROFILE

echo "Internet Gateway Created and Attached: $IGW_ID"

# Create Route Table and Route to Internet
echo "Creating Route Table..."
ROUTE_TABLE_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=QueenOge-Route-Table}]" \
  --query 'RouteTable.RouteTableId' --output text \
  --region $REGION --profile $PROFILE)

aws ec2 create-route \
  --route-table-id $ROUTE_TABLE_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID \
  --region $REGION --profile $PROFILE

# Associate Route Table with Web Subnet
aws ec2 associate-route-table \
  --route-table-id $ROUTE_TABLE_ID \
  --subnet-id $WEB_SUBNET_ID \
  --region $REGION --profile $PROFILE

# Enable auto-assign public IP on Web Subnet
echo "Enabling auto-assign public IP for Web Subnet..."
aws ec2 modify-subnet-attribute \
  --subnet-id $WEB_SUBNET_ID \
  --map-public-ip-on-launch \
  --region $REGION --profile $PROFILE

echo "QueenOge VPC Multi-Tier Architecture setup complete!"
