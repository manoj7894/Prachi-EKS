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


# Install AWS CLI
echo "Installing AWS CLI..."
sudo apt-get install -y curl unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws
echo "AWS CLI installation complete."


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


# Install containerd
sudo yum install -y containerd
sudo systemctl enable containerd --now


# Install Kubernetes components (kubeadm, kubelet, kubectl)
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

# Final message
echo "All installations completed successfully."





# set -e  # Exit immediately if a command exits with a non-zero status
# set -o pipefail  # Prevent errors in pipelines from being masked

# # Update and install required dependencies
# echo "Updating system and installing dependencies..."
# sudo apt update && sudo apt install -y awscli curl unzip jq apt-transport-https ca-certificates

# # Install kubectl
# echo "Installing kubectl..."
# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# chmod +x kubectl
# sudo mv kubectl /usr/local/bin/
# kubectl version --client

# # Install eksctl
# echo "Installing eksctl..."
# curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" | tar xz -C /tmp
# sudo mv /tmp/eksctl /usr/local/bin
# eksctl version

# # Install kubelet and kubeadm
# echo "Setting up Kubernetes repositories..."
# sudo mkdir -p /etc/apt/keyrings
# curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo tee /etc/apt/keyrings/kubernetes-apt-keyring.asc >/dev/null
# echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.asc] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list >/dev/null

# echo "Installing kubelet and kubeadm..."
# sudo apt update
# sudo apt install -y kubelet kubeadm

# # Prevent automatic updates of kubelet and kubeadm
# echo "Holding kubelet and kubeadm versions..."
# sudo apt-mark hold kubelet kubeadm

# echo "Installation completed successfully!"
