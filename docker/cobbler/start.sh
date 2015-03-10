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

# Run puppet to apply custom config
puppet apply -v /etc/puppet/modules/nailgun/examples/cobbler-only.pp
# Stop cobbler and dnsmasq
pkill dnsmasq
pkill cobblerd

# Running services
/usr/sbin/dnsmasq
cobblerd -F
