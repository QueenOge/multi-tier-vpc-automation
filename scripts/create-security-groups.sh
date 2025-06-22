#!/bin/bash

PROFILE="queenoge"
REGION="us-east-1"

echo "Creating Security Groups..."

# Get VPC ID (assumes only one VPC in this region with your tag)
VPC_ID=$(aws ec2 describe-vpcs \
  --filters "Name=tag:Name,Values=QueenOge-VPC" \
  --query "Vpcs[0].VpcId" \
  --output text \
  --region $REGION --profile $PROFILE)

# Web SG
WEB_SG_ID=$(aws ec2 create-security-group \
  --group-name QueenOge-Web-SG \
  --description "Allow HTTP and SSH from anywhere" \
  --vpc-id $VPC_ID \
  --query 'GroupId' \
  --output text \
  --region $REGION --profile $PROFILE)

aws ec2 authorize-security-group-ingress \
  --group-id $WEB_SG_ID \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0 \
  --region $REGION --profile $PROFILE

aws ec2 authorize-security-group-ingress \
  --group-id $WEB_SG_ID \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0 \
  --region $REGION --profile $PROFILE

# App SG
APP_SG_ID=$(aws ec2 create-security-group \
  --group-name QueenOge-App-SG \
  --description "Allow access from Web SG" \
  --vpc-id $VPC_ID \
  --query 'GroupId' \
  --output text \
  --region $REGION --profile $PROFILE)

aws ec2 authorize-security-group-ingress \
  --group-id $APP_SG_ID \
  --protocol tcp \
  --port 80 \
  --source-group $WEB_SG_ID \
  --region $REGION --profile $PROFILE

# DB SG
DB_SG_ID=$(aws ec2 create-security-group \
  --group-name QueenOge-DB-SG \
  --description "Allow MySQL from App SG" \
  --vpc-id $VPC_ID \
  --query 'GroupId' \
  --output text \
  --region $REGION --profile $PROFILE)

aws ec2 authorize-security-group-ingress \
  --group-id $DB_SG_ID \
  --protocol tcp \
  --port 3306 \
  --source-group $APP_SG_ID \
  --region $REGION --profile $PROFILE

echo "Security Groups Created:"
echo "  Web SG: $WEB_SG_ID"
echo "  App SG: $APP_SG_ID"
echo "  DB SG:  $DB_SG_ID"

