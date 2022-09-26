#/bin/bash
cd /opt
git clone https://github.com/kamailio/kamailio.git kamailio
cd kamailio
git checkout -b 5.3 origin/5.3
make cfg; make all; make install