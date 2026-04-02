#!/bin/bash

sudo apt install mysql-client-core-8.0

# Install Docker
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo usermod -a -G docker ubuntu
newgrp docker

systemctl start docker
systemctl enable docker

# Clone repository and run app
cd /home/ubuntu

git clone https://github.com/dhpasta/ObliczaKalisza.git

cd ObliczaKalisza
mv docker-compose.yml docker-compose-local.yml
mv docker-compose-aws.yml docker-compose.yml
mv connect.py connect-local.py
mv connect-aws.py connect.py
docker compose up