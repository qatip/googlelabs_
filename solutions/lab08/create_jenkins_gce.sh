#!/bin/bash

# Variables
PROJECT_ID="<your lab project id>"
REGION="us-west1"
ZONE="us-west1-a"
NETWORK_NAME="jenkins-network"
SUBNET_NAME="jenkins-subnet"
FIREWALL_RULE_NAME="jenkins-firewall"
INSTANCE_NAME="jenkins-instance"
MACHINE_TYPE="e2-small"
IMAGE_PROJECT="ubuntu-os-cloud"
IMAGE_FAMILY="ubuntu-2204-lts"
TAGS="http-server,https-server"
SERVICE_ACCOUNT="<your lab project id>@<your lab project id>.iam.gserviceaccount.com"

# Ensure the project is set
gcloud config set project $PROJECT_ID

# Enable required APIs
echo "Enabling required APIs..."
gcloud services enable compute.googleapis.com --project $PROJECT_ID

# Create VPC
echo "Creating VPC..."
gcloud compute networks create $NETWORK_NAME --subnet-mode=custom --project=$PROJECT_ID || echo "VPC may already exist."
# Create Subnet
echo "Creating Subnet..."
gcloud compute networks subnets create $SUBNET_NAME --network=$NETWORK_NAME --region=$REGION --range=10.0.1.0/24 --project=$PROJECT_ID || echo "Subnet may already exist."
# Create Firewall Rules
echo "Creating Firewall Rules..."
gcloud compute firewall-rules create $FIREWALL_RULE_NAME --network=$NETWORK_NAME --allow tcp:22,tcp:80,tcp:8080 --target-tags=$TAGS --description="Allow SSH, HTTP, and Jenkins access" --project=$PROJECT_ID || echo "Firewall rule may already exist."

# Create VM Instance
echo "Creating Compute Engine instance..."
gcloud compute instances create $INSTANCE_NAME \
    --zone=$ZONE \
    --machine-type=$MACHINE_TYPE \
    --subnet=$SUBNET_NAME \
    --network-tier=PREMIUM \
    --tags=$TAGS \
    --image-family=$IMAGE_FAMILY \
    --image-project=$IMAGE_PROJECT \
    --service-account=$SERVICE_ACCOUNT \
    --metadata-from-file startup-script=jenkins_startup_script.sh \
    --project=$PROJECT_ID

# Wait for the instance to initialize
echo "Waiting 6 minutes for the instance to fully initialize. Please be patient..."
for i in {6..1}; do
    echo "Still waiting... $i minute(s) remaining."
    sleep 60
done

# Retrieve External IP Address
INSTANCE_IP=$(gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE --format="get(networkInterfaces[0].accessConfigs[0].natIP)" --project=$PROJECT_ID)
echo "Instance is accessible at IP: http://$INSTANCE_IP:8080"

# ---- Serial console password retrieval (no SSH) ----
echo "Waiting for Jenkins initial admin password on serial console..."
PASSWORD=""
for i in {1..180}; do  # ~30 minutes, 10s interval
  SERIAL_OUT=$(gcloud compute instances get-serial-port-output "$INSTANCE_NAME" --zone="$ZONE" --port=1 --project="$PROJECT_ID" 2>/dev/null || true)
  PASSWORD=$(echo "$SERIAL_OUT" | grep 'JENKINS_INITIAL_ADMIN_PASSWORD:' | tail -n1 | sed 's/.*JENKINS_INITIAL_ADMIN_PASSWORD://')
  if [[ -n "$PASSWORD" ]]; then
    echo "Jenkins initial admin password: $PASSWORD"
    break
  fi
  if (( i % 6 == 0 )); then
    echo "  ...still waiting (attempt $i/180)"
  fi
  sleep 10
done

if [[ -z "$PASSWORD" ]]; then
  echo "Failed to retrieve the Jenkins password from serial console. You can try manually with:"
  echo "  gcloud compute instances get-serial-port-output $INSTANCE_NAME --zone=$ZONE --port=1 | grep 'JENKINS_INITIAL_ADMIN_PASSWORD:' | tail -n1 | sed 's/.*JENKINS_INITIAL_ADMIN_PASSWORD://'"
fi
