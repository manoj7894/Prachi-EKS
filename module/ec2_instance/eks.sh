#!/bin/bash

# Update package list
echo "Updating package list..."
sudo apt-get update -y



# Install Java
sudo apt-get update
sudo apt-get install fontconfig openjdk-17-jre -y



# Install Docker
# Add Docker's official GPG key
sudo apt-get update -y
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo chmod 666 /var/run/docker.sock
sudo usermod -aG docker ubuntu
sudo systemctl enable docker
sudo systemctl start docker
echo "Docker installation complete."



# Install Maven
# Maven will be updated automatically by the package manager
sudo apt-get update -y
sudo apt-get install maven -y
mvn -version
echo "Maven installation complete."



# Install Git
# Git will be updated automatically by the package manager
sudo apt-get update -y
sudo apt-get install git -y
git --version
echo "Git installation complete."



# Install Trivy-Scanner
sudo apt-get install wget apt-transport-https gnupg lsb-release -y
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy
echo "Trivy installation complete."



# Install NPM
sudo apt install npm -y



# Install AWS_CLI
sudo apt-get update -y
sudo apt-get install -y curl unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install



# Install kubectl
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo chmod +x kubectl
sudo mv kubectl /usr/local/bin/
echo "kubectl installation complete."


# Install eksctl
echo "Installing eksctl..."
curl -sSL "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" | tar xz
sudo mv eksctl /usr/local/bin/
echo "eksctl installation complete."


# Install Kubernetes components
echo "Installing Kubernetes components..."
sudo rm -f /etc/apt/sources.list.d/kubernetes.list
sudo apt update && sudo apt install -y curl gnupg2
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo tee /etc/apt/trusted.gpg.d/kubernetes.asc

echo "deb https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
echo "Kubernetes installation complete."





# Install SonarQube
# Install unzip if not already installed
sudo apt-get install unzip -y

# Create a user for SonarQube
sudo adduser --disabled-password --gecos 'SonarQube' sonarqube

# Switch to SonarQube user and install SonarQube
sudo su - sonarqube <<EOF
# Fetch the latest SonarQube version from the official source
SONARQUBE_VERSION=$(curl -s https://api.github.com/repos/SonarSource/sonarqube/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
SONARQUBE_URL="https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip"

# Download and extract SonarQube
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.4.0.54424.zip
unzip sonarqube-9.4.0.54424.zip
chmod -R 755 /home/sonarqube/sonarqube-9.4.0.54424
# Change ownership
chown -R sonarqube:sonarqube /home/sonarqube/sonarqube-9.4.0.54424
# Start SonarQube
cd sonarqube-9.4.0.54424/bin/linux-x86-64/
./sonar.sh start
EOF

echo "Installation complete. Jenkins, Docker, Maven, Git, and SonarQube are set up."
echo "Sonarqube installation complete."

# Final message
echo "All installations completed successfully."