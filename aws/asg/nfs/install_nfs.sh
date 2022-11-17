#!/bin/bash
sudo fdisk -l
sudo dnf install nfs-utils -y
sudo systemctl start nfs-server.servic
sudo systemctl start nfs-server.service
sudo systemctl enable nfs-server.service
sudo systemctl status nfs-server.service
rpcinfo -p | grep nfs
sudo mkdir -p /mnt/nfs_shares/
sudo chown -R nobody: /mnt/nfs_shares
sudo chmod -R 777 /mnt/nfs_shares/
sudo systemctl restart nfs-utils.service
sudo cp /etc/nfs.conf /etc/nfs.conf_back
sudo cp /etc/nfsmount.conf /etc/nfsmount.conf_back
sudo cp /etc/exports /etc/exports_back
# sudo nano /etc/nfs.conf
# sudo nano /etc/nfsmount.conf
sudo tee /etc/exports << EOF 
/mnt/nfs_shares/   127.30.5.155(rw,no_root_squash,sync,no_subtree_check)  127.30.5.24(rw,no_root_squash,sync,no_subtree_check)
EOF
#sudo nano /etc/exports
sudo systemctl restart nfs-utils.service
sudo systemctl status nfs-utils.service
sudo firewall-cmd --permanent --add-service=nfs
sudo firewall-cmd --permanent --add-service=rpc-bind
sudo firewall-cmd --permanent --add-service=mountd
sudo firewall-cmd --reload
ip a