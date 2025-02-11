#!/bin/bash

set -e 
echo "Updating package lists..."
sudo apt update -y

echo "Installing dependencies..."
sudo apt install -y curl wget jq bash-completion unzip software-properties-common

# kubectl
echo "Installing kubectl..."
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

# Helm
echo "Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version

# k9s
echo "Installing k9s..."
K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | jq -r '.tag_name')
curl -LO "https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz"
tar -xvf k9s_Linux_amd64.tar.gz
sudo mv k9s /usr/local/bin/
rm k9s_Linux_amd64.tar.gz
k9s version

# Ansible
echo "Installing Ansible..."
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible
ansible --version

# Kustomize
echo "Installing Kustomize..."
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
sudo mv kustomize /usr/local/bin/
kustomize version
