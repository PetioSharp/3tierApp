#!/bin/bash

# Check if the AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI not found. Please install it before running this script."
    exit 1
fi

# Define the action (start or stop)
ACTION=$1

# Check if the action parameter is provided and valid
if [[ "$ACTION" != "start" && "$ACTION" != "stop" ]]; then
    echo "Usage: $0 <start|stop>"
    exit 1
fi

# Fetch all instance IDs
INSTANCE_IDS=$(aws ec2 describe-instances --query "Reservations[*].Instances[*].InstanceId" --output text)

# Check if there are any instances to manage
if [[ -z "$INSTANCE_IDS" ]]; then
    echo "No EC2 instances found in your account."
    exit 0
fi

# Start or stop instances based on the action
if [[ "$ACTION" == "start" ]]; then
    echo "Starting all EC2 instances..."
    aws ec2 start-instances --instance-ids $INSTANCE_IDS
    echo "All EC2 instances are being started."
elif [[ "$ACTION" == "stop" ]]; then
    echo "Stopping all EC2 instances..."
    aws ec2 stop-instances --instance-ids $INSTANCE_IDS
    echo "All EC2 instances are being stopped."
fi
