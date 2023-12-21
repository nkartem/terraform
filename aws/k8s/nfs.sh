#https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nfs-mount-on-rocky-linux-8
#!/bin/bash
#server
echo "Install nfs server"
sudo dnf update -y
sudo dnf -y install nfs-utils 


sudo mkdir /opt/UIS -p
ls -dl /opt/UIS
sudo chown nobody /opt/UIS
sudo tee -a /etc/exports <<EOF
/opt/UIS            client_ip(rw,sync,no_root_squash,no_subtree_check)
EOF

sudo systemctl enable nfs-server
sudo systemctl start nfs-server
sudo systemctl status nfs-server

sudo firewall-cmd --permanent --list-all | grep services
sudo firewall-cmd --permanent --add-service=nfs
sudo firewall-cmd --permanent --add-service=mountd
sudo firewall-cmd --permanent --add-service=rpc-bind
sudo firewall-cmd --reload
sudo firewall-cmd --permanent --list-all | grep services

#server
# echo "Install nfs client"
# sudo mkdir -p /opt/UIS
# sudo mount host_ip:/var/nfs/general /nfs/general
# sudo mount host_ip:/home /nfs/home
# df -h
# sudo tee -a /etc/fstab <<EOF
# host_ip:/opt/UIS     /opt/UIS    nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
# EOF