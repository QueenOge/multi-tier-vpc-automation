#!/bin/bash

# Variables
PROFILE="queenoge"
REGION="us-east-1"
AMI_ID="ami-0c101f26f147fa7fd"  # Amazon Linux 2 for us-east-1
INSTANCE_TYPE="t2.micro"
KEY_NAME="QueenOge-KeyPair"
WEB_SG_ID="sg-04290a11f8f507c99"  
APP_SG_ID="sg-0b2bb4e4cfba97c19"  
DB_SG_ID="sg-0b9dbd68d94616d2b"   
WEB_SUBNET_ID="subnet-05a913af15a123d10"  
APP_SUBNET_ID="subnet-0fdf6f00ca91aeb71"
DB_SUBNET_ID="subnet-0641ef5e59466ab0f"

# Web Tier Instance
echo "Launching Web Instance..."
WEB_INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --subnet-id $WEB_SUBNET_ID \
  --security-group-ids $WEB_SG_ID \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=QueenOge-Web-Server}]" \
  --associate-public-ip-address \
  --query 'Instances[0].InstanceId' --output text \
  --region $REGION --profile $PROFILE)

# App Tier Instance
echo "Launching App Instance..."
APP_INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --subnet-id $APP_SUBNET_ID \
  --security-group-ids $APP_SG_ID \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=QueenOge-App-Server}]" \
  --query 'Instances[0].InstanceId' --output text \
  --region $REGION --profile $PROFILE)

# DB Tier Instance
echo "Launching DB Instance..."
DB_INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --subnet-id $DB_SUBNET_ID \
  --security-group-ids $DB_SG_ID \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=QueenOge-DB-Server}]" \
  --query 'Instances[0].InstanceId' --output text \
  --region $REGION --profile $PROFILE)

echo "Instances Launched:"
echo "  Web Server: $WEB_INSTANCE_ID"
echo "  App Server: $APP_INSTANCE_ID"
echo "  DB Server:  $DB_INSTANCE_ID"
