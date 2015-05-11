#!/bin/bash

# Clean rpm locks before puppet run.
# See ticket https://bugs.launchpad.net/fuel/+bug/1339236
rm -f /var/lib/rpm/__db.*
rpm --rebuilddb

mkdir -p /var/log/cobbler/{anamon,kicklog,syslog,tasks}

# reset authorized_keys file so puppet can a write new one
rm -f /etc/cobbler/authorized_keys

# Make sure services are not running (no pids, etc), puppet will
# configure and bring them up.
pkill httpd
pkill xinetd

#Workaround for facter to detect docker
grep -q '/system.slice/dock' /proc/1/cgroup && sed -i 's/\/docker\//\/system\.slice\/docker/' /usr/share/ruby/vendor_ruby/facter/util/virtual.rb

# Run puppet to apply custom config
puppet apply -v /etc/puppet/modules/nailgun/examples/cobbler-only.pp

#Workaround for cobbler to restart dnsmasq inside docker instance
sed -i 's/service dnsmasq restart/pkill dnsmasq \&\& \/usr\/sbin\/dnsmasq/' /usr/lib/python2.7/site-packages/cobbler/action_sync.py
sed -i 's/service dnsmasq restart/pkill dnsmasq \&\& \/usr\/sbin\/dnsmasq/' /usr/lib/python2.7/site-packages/cobbler/modules/sync_post_restart_services.py
rm -f /usr/lib/python2.7/site-packages/cobbler/action_sync.py{c,o}
rm -f /usr/lib/python2.7/site-packages/cobbler/modules/sync_post_restart_services.py{c,o}

# Stop cobbler and dnsmasq
pkill dnsmasq
pkill cobblerd

# Running services
/usr/sbin/dnsmasq
cobblerd -F
