#!/bin/bash

# Define log file
LOG_FILE="/var/log/jenkins_setup.log"

# Ensure log file exists
sudo touch $LOG_FILE
sudo chmod 644 $LOG_FILE

# Update system
echo "Updating system..." | sudo tee -a $LOG_FILE
sudo apt update -y && sudo apt upgrade -y >> $LOG_FILE 2>&1

# Install dependencies
echo "Installing Java, curl, and unzip..." | sudo tee -a $LOG_FILE
sudo apt install -y openjdk-17-jdk unzip curl >> $LOG_FILE 2>&1

# Add Jenkins repo and key
echo "Adding Jenkins repository..." | sudo tee -a $LOG_FILE
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins
echo "Installing Jenkins..." | sudo tee -a $LOG_FILE
sudo apt update -y >> $LOG_FILE 2>&1
sudo apt install -y jenkins >> $LOG_FILE 2>&1

# Start and enable Jenkins
echo "Starting Jenkins service..." | sudo tee -a $LOG_FILE
sudo systemctl start jenkins >> $LOG_FILE 2>&1
sudo systemctl enable jenkins >> $LOG_FILE 2>&1

# Allow Jenkins to run sudo commands
echo "Configuring sudo permissions for Jenkins..." | sudo tee -a $LOG_FILE
echo "jenkins ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/jenkins
sudo chmod 440 /etc/sudoers.d/jenkins

# --- Emit Jenkins initial admin password to serial console (no SSH required) ---
echo "Waiting for Jenkins initial admin password..." | sudo tee -a $LOG_FILE
for i in {1..360}; do  # up to ~30 minutes
  if [[ -s /var/lib/jenkins/secrets/initialAdminPassword ]]; then
    PW="$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)"
    echo "JENKINS_INITIAL_ADMIN_PASSWORD:$PW" | sudo tee -a $LOG_FILE
    # Write to serial console (GCE port 1 is /dev/ttyS0)
    echo "JENKINS_INITIAL_ADMIN_PASSWORD:$PW" | sudo tee /dev/ttyS0 > /dev/null 2>&1 || true
    break
  fi
  sleep 5
done
