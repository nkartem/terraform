#! /bin/bash
sudo amazon-linux-extras install epel
sudo yum install s3fs-fuse -y
sudo mkdir -p /var/s3fs-demofs

#sudo s3fs -o iam_role="s3full" -o url="https://s3-eu-central-1.amazonaws.com" -o endpoint=eu-central-1 -o dbglevel=info -o curldbg -o allow_other -o use_cache=/tmp bucketname-kafka /var/s3fs-demofs
########sudo s3fs bucketname-kafka /var/s3fs-demofs fuse _netdev,allow_other,iam_role=auto 0 0
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