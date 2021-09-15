#!/bin/bash
sudo apt -y update
sudo apt -y upgrade
sudo apt -y install apache2
sudo systemctl enable apache2.service
sudo systemctl start apache2.service
sudo ufw allow 80/tcp comment 'accept Apache'
sudo ufw allow 443/tcp comment 'accept HTTPS connections'

sudo apt -y update
sudo apt -y install php libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip php-json
sudo systemctl restart apache2.service

cat <<EOF >/var/www/html/phpinfo.php
<?php
 phpinfo();
 ?>
EOF

sudo apt -y update
cd /tmp
tar xzvf latest.tar.gz
sudo touch /tmp/wordpress/.htaccess
sudo cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
sudo mkdir /tmp/wordpress/wp-content/upgrade
sudo cp -a /tmp/wordpress/. /var/www/html/wordpress

sudo apt -y update
#sudo apt -y install phpmyadmin

# sudo apt -y update
# sudo apt -y mariadb-server mariadb-client
# sudo -y mysql_secure_installation