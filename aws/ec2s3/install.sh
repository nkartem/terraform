#! /bin/bash
sudo amazon-linux-extras install epel
sudo yum install s3fs-fuse -y
#docker
sudo amazon-linux-extras install docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo chkconfig docker on
sudo yum install -y git
wget https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) 
sudo mv docker-compose-$(uname -s)-$(uname -m) /usr/local/bin/docker-compose
sudo chmod -v +x /usr/local/bin/docker-compose
sudo systemctl enable docker.service
sudo systemctl start docker.service
cd /opt/
sudo git clone https://github.com/nkartem/docker.git
cd /opt/docker/kafka/kafka-serv
#docker-compose up -d


