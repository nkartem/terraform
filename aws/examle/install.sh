#! /bin/bash
sudo amazon-linux-extras list | grep epel
sudo amazon-linux-extras enable epel
sudo yum install -y epel-release
sudo yum update -y
sudo yum -y install nginx
sudo systemctl start nginx
sudo systemctl enable nginx
sudo echo "TERRAFORM+Jenkins" >> /usr/share/nginx/html/index.html