#!/bin/bash
sudo apt -y update
sudo apt -y upgrade
sudo apt -y install apache2
sudo systemctl enable apache2.service
sudo systemctl start apache2.service
sudo ufw allow 80/tcp comment 'accept Apache'
sudo ufw allow 443/tcp comment 'accept HTTPS connections'