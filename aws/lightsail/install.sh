#! /bin/bash
touch /home/bitnami/myfile.txt

mkdir /opt/bitnami/projects
chown bitnami:bitnami /opt/bitnami/projects
cd /opt/bitnami/projects

###############################
touch /opt/bitnami/apache/conf/vhosts/myapp-http-vhost.conf
cat > /opt/bitnami/apache/conf/vhosts/myapp-http-vhost.conf <<EOF
  <VirtualHost _default_:80>
    ServerAlias *
    DocumentRoot "/opt/bitnami/projects/myapp/public"
    <Directory "/opt/bitnami/projects/myapp/public">
      Require all granted
    </Directory>
    ProxyPass / http://localhost:3000/
    ProxyPassReverse / http://localhost:3000/
  </VirtualHost>
EOF

touch /opt/bitnami/apache/conf/vhosts/myapp-https-vhost.conf
cat > /opt/bitnami/apache/conf/vhosts/myapp-https-vhost.conf <<EOF
  <VirtualHost _default_:443>
    ServerAlias *
    SSLEngine on
    SSLCertificateFile "/opt/bitnami/apache/conf/bitnami/certs/server.crt"
    SSLCertificateKeyFile "/opt/bitnami/apache/conf/bitnami/certs/server.key"
    DocumentRoot "/opt/bitnami/projects/myapp"
    <Directory "/opt/bitnami/projects/myapp">
      Require all granted
    </Directory>
    ProxyPass / http://localhost:3000/
    ProxyPassReverse / http://localhost:3000/
  </VirtualHost>
EOF
/opt/bitnami/ctlscript.sh restart apache
###########################
cd /opt/bitnami/projects
sudo -H -u bitnami -c 'express --view pug /opt/bitnami/projects/myapp'
#express --view pug /opt/bitnami/projects/myapp
cd /opt/bitnami/projects/myapp
npm install
#DEBUG=myapp:* ./bin/www 
forever start /opt/bitnami/projects/myapp/bin/www

# cp /opt/bitnami/apache/conf/vhosts/sample-vhost.conf.disabled /opt/bitnami/apache/conf/vhosts/sample-vhost.conf
# cp /opt/bitnami/apache/conf/vhosts/sample-https-vhost.conf.disabled /opt/bitnami/apache/conf/vhosts/sample-https-vhost.conf