#!/bin/bash

set -e

echo "======================"
echo "Setup"
echo "======================"

# 패키지 설치 함수
install_package() {
    local package_name=$1
    echo "Checking for $package_name..."

    if ! command -v $package_name &> /dev/null; then
        echo "$package_name not found, installing..."
        if command -v yum &> /dev/null; then
            sudo yum install -y $package_name
        else
            echo "$package_name 설치 실패. yum을 지원하지 않는 시스템입니다. 수동 설치 후 다시 시도하세요."
            exit 1
        fi
    else
        echo "$package_name is already installed: $(which $package_name)"
    fi
}

echo "Checking for prerequisites..."
install_package curl
install_package git
install_package gpg
install_package jq
install_package tar

ARCH=$(uname -m)
echo "Architecture: $ARCH"
if [ "$ARCH" != "x86_64" ]; then
  echo "Warning: 이 스크립트는 x86_64 아키텍처 기준입니다."
  read -p "계속 진행하시겠습니까? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# Docker 설치
echo "Installing docker..."
if ! command -v docker &>/dev/null; then
    sudo yum update -y
    sudo yum install -y docker
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker $USER
    echo "Docker 설치 완료 (그룹 적용 위해 로그아웃/재로그인 권장)"
else
    echo "Docker is already installed: $(which docker)"
fi

# Docker Compose 설치
echo "Installing docker-compose..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# k3s 설치
echo "Installing k3s..."
curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644

# KUBECONFIG 환경변수 설정
echo "Setting KUBECONFIG environment variable..."
KUBECONFIG_LINE='export KUBECONFIG=/etc/rancher/k3s/k3s.yaml'
grep -qF "$KUBECONFIG_LINE" ~/.bashrc || echo "$KUBECONFIG_LINE" >> ~/.bashrc
grep -qF "$KUBECONFIG_LINE" ~/.zshrc 2>/dev/null || echo "$KUBECONFIG_LINE" >> ~/.zshrc 2>/dev/null
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# kubectl 설치 (k3s에 포함)
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

echo "Testing kubectl..."
kubectl get nodes

# k9s 설치
echo "Installing k9s..."
K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | jq -r .tag_name)
curl -LO "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz"
tar -zxvf k9s_Linux_amd64.tar.gz
sudo mv k9s /usr/local/bin/
rm k9s_Linux_amd64.tar.gz

# helm 설치
echo "Installing helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# terraform 설치
echo "Installing terraform..."
TERRAFORM_VERSION=$(curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | jq -r .tag_name)
curl -LO "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
unzip -o "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
sudo mv terraform /usr/local/bin/
rm "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

# argocd 설치 (helm으로)
echo "Installing argocd..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd

# 완료 메시지
echo "========================================"
echo "Installation Complete!"
echo "========================================"
echo "k3s, kubectl, k9s, helm, terraform, docker, docker-compose가 설치되었습니다."
echo "kubectl을 바로 사용하려면 셸을 재시작하거나 아래 실행:"
echo "  export KUBECONFIG=/etc/rancher/k3s/k3s.yaml"
echo "  source ~/.bashrc"
echo "설치 상태 확인:"
echo "  docker --version"
echo "  docker-compose --version"
echo "  k3s --version"
echo "  kubectl get nodes"
echo "  k9s version"
echo "  helm version"
echo "  terraform version"
echo "========================================"

