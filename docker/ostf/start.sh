#!/bin/bash

# Clean rpm locks before puppet run.
# See ticket https://bugs.launchpad.net/fuel/+bug/1339236
rm -f /var/lib/rpm/__db.*
rpm --rebuilddb

#Workaround for facter to detect docker
grep -q '/system.slice/dock' /proc/1/cgroup && sed -i 's/\/docker\//\/system\.slice\/docker/' /usr/share/ruby/vendor_ruby/facter/util/virtual.rb

#Workaround to pass python packages version dependencies
sed -i 's/gevent==0.13.8/gevent>=0.13.8/' /usr/lib/python2.7/site-packages/fuel_ostf-*.egg-info/requires.txt

puppet apply -v /etc/puppet/modules/nailgun/examples/ostf-only.pp

pgrep supervisord >/dev/null && /usr/bin/supervisorctl shutdown
while pgrep supervisord >/dev/null; do sleep 1; done
/usr/bin/supervisord -n
