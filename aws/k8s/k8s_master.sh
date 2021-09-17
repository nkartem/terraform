#!/bin/bash
sudo apt -y update
sudo apt -y upgrade
sudo apt -y install apt-transport-https curl
# Install docker
sudo apt -y install docker.io
sudo systemctl enable docker
sudo systemctl start docker
# Install kubelet, kubeadm and kubectl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt -y install kubeadm kubelet kubectl kubernetes-cni
# Disable Swap
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a
# init kuber
sudo kubeadm init
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config