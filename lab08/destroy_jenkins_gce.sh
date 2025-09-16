#!/bin/bash
set -euo pipefail

# --- Config (override with env vars if you like) ---
PROJECT_ID="${PROJECT_ID:-<your lab project id>}"
REGION="${REGION:-us-west1}"
ZONE="${ZONE:-us-west1-a}"
NETWORK_NAME="${NETWORK_NAME:-jenkins-network}"
SUBNET_NAME="${SUBNET_NAME:-jenkins-subnet}"
FIREWALL_RULE_NAME="${FIREWALL_RULE_NAME:-jenkins-firewall}"
INSTANCE_NAME="${INSTANCE_NAME:-jenkins-instance}"

echo "Using project: $PROJECT_ID"
gcloud config set project "$PROJECT_ID" >/dev/null

# --- Delete VM instance (and its boot disk) ---
echo "Deleting instance: $INSTANCE_NAME (zone: $ZONE)"
gcloud compute instances delete "$INSTANCE_NAME" --zone "$ZONE" --quiet || echo "Instance not found or already deleted."

# Some images can leave extra disks if auto-delete was disabled; try best-effort cleanup
echo "Attempting to delete any lingering disk named like the instance (best-effort)..."
gcloud compute disks delete "$INSTANCE_NAME" --zone "$ZONE" --quiet || true

# --- Delete firewall rule ---
echo "Deleting firewall rule: $FIREWALL_RULE_NAME"
gcloud compute firewall-rules delete "$FIREWALL_RULE_NAME" --quiet || echo "Firewall rule not found or already deleted."

# --- Delete subnet ---
echo "Deleting subnet: $SUBNET_NAME (region: $REGION)"
gcloud compute networks subnets delete "$SUBNET_NAME" --region "$REGION" --quiet || echo "Subnet not found or already deleted."

# --- Delete VPC network ---
echo "Deleting VPC network: $NETWORK_NAME"
gcloud compute networks delete "$NETWORK_NAME" --quiet || echo "Network not found or already deleted."

echo "✅ Cleanup complete."
