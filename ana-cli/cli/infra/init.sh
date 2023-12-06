#!/usr/bin/env bash

# Install Nvidia container toolkit 
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
  sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list \
  && sudo apt-get update

sudo apt update && sudo apt upgrade

sudo apt install -y build-essential git vim docker.io 

# Install Nvidia container toolkit 
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
  sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list \
  && sudo apt-get update

# Do we need to restart after this?
sudo apt-get install -y nvidia-container-toolkit

# Cofigure the toolkit for use with Docker 
sudo nvidia-ctk runtime configure --runtime=docker

sudo systemctl restart docker

sudo apt-get install linux-headers-$(uname -r)

git clone https://github.com/austinagii/Senti.git

cd ./Senti/sentiment-api





