#! /bin/bash
touch /home/bitnami/myfile.txt

mkdir /opt/bitnami/projects
#chown $USER /opt/bitnami/projects
cd /opt/bitnami/projects
express --view pug /opt/bitnami/projects/sample
cd /opt/bitnami/projects/sample
npm install
DEBUG=sample:* ./bin/www
forever start /opt/bitnami/projects/sample/bin/www
cp /opt/bitnami/apache/conf/vhosts/sample-vhost.conf.disabled /opt/bitnami/apache/conf/vhosts/sample-vhost.conf
cp /opt/bitnami/apache/conf/vhosts/sample-https-vhost.conf.disabled /opt/bitnami/apache/conf/vhosts/sample-https-vhost.conf
/opt/bitnami/ctlscript.sh restart apache
