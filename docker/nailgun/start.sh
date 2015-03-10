#!/bin/bash

# Clean rpm locks before puppet run.
# See ticket https://bugs.launchpad.net/fuel/+bug/1339236
rm -f /var/lib/rpm/__db.*
rpm --rebuilddb

#Workaround to pass python packages version dependencies
sed -i 's/Jinja2==2.7/Jinja2>=2.7/' /usr/lib/python2.7/site-packages/nailgun-*.egg-info/requires.txt
sed -i 's/Mako==0.9.1/Mako/' /usr/lib/python2.7/site-packages/nailgun-*.egg-info/requires.txt
sed -i 's/MarkupSafe==0.18/MarkupSafe/' /usr/lib/python2.7/site-packages/nailgun-*.egg-info/requires.txt
sed -i '/argparse==1.2.1/d' /usr/lib/python2.7/site-packages/nailgun-*.egg-info/requires.txt
sed -i 's/fysom==1.0.11/fysom>=1.0.11/' /usr/lib/python2.7/site-packages/nailgun-*.egg-info/requires.txt
sed -i 's/iso8601==0.1.9/iso8601>=0.1.9/' /usr/lib/python2.7/site-packages/nailgun-*.egg-info/requires.txt
sed -i 's/kombu==3.0.16/kombu/' /usr/lib/python2.7/site-packages/nailgun-*.egg-info/requires.txt
sed -i 's/urllib3==1.7/urllib3>=1.7/' /usr/lib/python2.7/site-packages/nailgun-*.egg-info/requires.txt
sed -i 's/amqp>=1.0.13,<1.1.0/amqp/' /usr/lib/python2.7/site-packages/kombu-*.egg-info/requires.txt

#Workaround so nailgun can see version.yaml
ln -sf /etc/fuel/version.yaml /etc/nailgun/version.yaml
#Run puppet to apply custom config
puppet apply -v /etc/puppet/modules/nailgun/examples/nailgun-only.pp

pgrep supervisord >/dev/null && /usr/bin/supervisorctl shutdown
while pgrep supervisord >/dev/null; do sleep 1; done
/usr/bin/supervisord -n
