#!/bin/bash

# QueenOge Full Automation Script - VPC Multi-Tier Architecture
# This script provisions the full architecture: VPC, Subnets, IGW, Routes, Security Groups, Key Pair, and EC2 Instances.

# ========= VARIABLES =========
PROFILE="queenoge"
REGION="us-east-1"
VPC_CIDR="10.0.0.0/16"
WEB_SUBNET_CIDR="10.0.1.0/24"
APP_SUBNET_CIDR="10.0.2.0/24"
DB_SUBNET_CIDR="10.0.3.0/24"
AZ1="us-east-1a"
AZ2="us-east-1b"
AZ3="us-east-1c"
KEY_NAME="QueenOge-KeyPair"
AMI_ID="ami-0c101f26f147fa7fd"
INSTANCE_TYPE="t2.micro"

mkdir -p scripts keys screenshots
chmod 700 keys

# ========= CREATE KEY PAIR =========
echo "Creating Key Pair..."
aws ec2 create-key-pair \
  --key-name $KEY_NAME \
  --query 'KeyMaterial' \
  --output text \
  --region $REGION --profile $PROFILE > keys/$KEY_NAME.pem
chmod 400 keys/$KEY_NAME.pem
echo "Key Pair saved to keys/$KEY_NAME.pem"

# ========= CREATE VPC =========
echo "Creating VPC..."
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block $VPC_CIDR \
  --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=QueenOge-VPC}]' \
  --query 'Vpc.VpcId' --output text \
  --region $REGION --profile $PROFILE)
echo "VPC ID: $VPC_ID"

# ========= CREATE SUBNETS =========
echo "Creating Subnets..."
WEB_SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID --cidr-block $WEB_SUBNET_CIDR --availability-zone $AZ1 \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=QueenOge-Web-Subnet}]' \
  --query 'Subnet.SubnetId' --output text --region $REGION --profile $PROFILE)

APP_SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID --cidr-block $APP_SUBNET_CIDR --availability-zone $AZ2 \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=QueenOge-App-Subnet}]' \
  --query 'Subnet.SubnetId' --output text --region $REGION --profile $PROFILE)

DB_SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID --cidr-block $DB_SUBNET_CIDR --availability-zone $AZ3 \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=QueenOge-DB-Subnet}]' \
  --query 'Subnet.SubnetId' --output text --region $REGION --profile $PROFILE)
echo "Subnets Created: $WEB_SUBNET_ID, $APP_SUBNET_ID, $DB_SUBNET_ID"

# ========= CREATE IGW + ROUTE =========
echo "Creating Internet Gateway..."
IGW_ID=$(aws ec2 create-internet-gateway \
  --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=QueenOge-IGW}]' \
  --query 'InternetGateway.InternetGatewayId' --output text --region $REGION --profile $PROFILE)
aws ec2 attach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID --region $REGION --profile $PROFILE
echo "Internet Gateway Attached: $IGW_ID"

echo "Creating Route Table..."
ROUTE_TABLE_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=QueenOge-Route-Table}]' \
  --query 'RouteTable.RouteTableId' --output text --region $REGION --profile $PROFILE)
aws ec2 create-route --route-table-id $ROUTE_TABLE_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID --region $REGION --profile $PROFILE
aws ec2 associate-route-table --route-table-id $ROUTE_TABLE_ID --subnet-id $WEB_SUBNET_ID --region $REGION --profile $PROFILE
aws ec2 modify-subnet-attribute --subnet-id $WEB_SUBNET_ID --map-public-ip-on-launch --region $REGION --profile $PROFILE

# ========= SECURITY GROUPS =========
echo "Creating Security Groups..."
WEB_SG_ID=$(aws ec2 create-security-group --group-name QueenOge-Web-SG --description "Web tier SG" --vpc-id $VPC_ID --query 'GroupId' --output text --region $REGION --profile $PROFILE)
APP_SG_ID=$(aws ec2 create-security-group --group-name QueenOge-App-SG --description "App tier SG" --vpc-id $VPC_ID --query 'GroupId' --output text --region $REGION --profile $PROFILE)
DB_SG_ID=$(aws ec2 create-security-group --group-name QueenOge-DB-SG --description "DB tier SG" --vpc-id $VPC_ID --query 'GroupId' --output text --region $REGION --profile $PROFILE)

# Add rules
aws ec2 authorize-security-group-ingress --group-id $WEB_SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0 --region $REGION --profile $PROFILE
aws ec2 authorize-security-group-ingress --group-id $WEB_SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $REGION --profile $PROFILE
aws ec2 authorize-security-group-ingress --group-id $APP_SG_ID --protocol tcp --port 80 --cidr $WEB_SUBNET_CIDR --region $REGION --profile $PROFILE
aws ec2 authorize-security-group-ingress --group-id $APP_SG_ID --protocol tcp --port 22 --cidr $WEB_SUBNET_CIDR --region $REGION --profile $PROFILE
aws ec2 authorize-security-group-ingress --group-id $DB_SG_ID --protocol tcp --port 3306 --cidr $APP_SUBNET_CIDR --region $REGION --profile $PROFILE
aws ec2 authorize-security-group-ingress --group-id $DB_SG_ID --protocol tcp --port 22 --cidr $APP_SUBNET_CIDR --region $REGION --profile $PROFILE
echo "Security Groups created and configured"

# ========= EC2 INSTANCES =========
echo "Launching EC2 Instances..."
WEB_INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID --count 1 --instance-type $INSTANCE_TYPE --key-name $KEY_NAME \
  --subnet-id $WEB_SUBNET_ID --security-group-ids $WEB_SG_ID \
  --associate-public-ip-address \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=QueenOge-Web-Server}]' \
  --query 'Instances[0].InstanceId' --output text --region $REGION --profile $PROFILE)

APP_INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID --count 1 --instance-type $INSTANCE_TYPE --key-name $KEY_NAME \
  --subnet-id $APP_SUBNET_ID --security-group-ids $APP_SG_ID \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=QueenOge-App-Server}]' \
  --query 'Instances[0].InstanceId' --output text --region $REGION --profile $PROFILE)

DB_INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID --count 1 --instance-type $INSTANCE_TYPE --key-name $KEY_NAME \
  --subnet-id $DB_SUBNET_ID --security-group-ids $DB_SG_ID \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=QueenOge-DB-Server}]' \
  --query 'Instances[0].InstanceId' --output text --region $REGION --profile $PROFILE)

echo "Instances Launched:"
echo "  Web: $WEB_INSTANCE_ID"
echo "  App: $APP_INSTANCE_ID"
echo "  DB : $DB_INSTANCE_ID"
echo "QueenOge Multi-Tier VPC Deployment Complete"
