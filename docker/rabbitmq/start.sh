#!/bin/bash -xe

# Clean rpm locks before puppet run.
# See ticket https://bugs.launchpad.net/fuel/+bug/1339236
rm -f /var/lib/rpm/__db.*
rpm --rebuilddb

mkdir -p /var/log/rabbitmq
chown -R rabbitmq:rabbitmq /var/log/rabbitmq

#Workaround for facter to detect docker
grep -q '/system.slice/dock' /proc/1/cgroup && sed -i 's/\/docker\//\/system\.slice\/docker/' /usr/share/ruby/vendor_ruby/facter/util/virtual.rb

exitcode=0
puppet apply --detailed-exitcodes -d -v /etc/puppet/modules/nailgun/examples/rabbitmq-only.pp || exitcode=$?
if [[ $exitcode != 0 && $exitcode != 2 ]]; then
  echo Puppet apply failed with exit code: $exitcode
  exit $exitcode
fi

su rabbitmq -s /bin/sh -c "cd /var/lib/rabbitmq; export HOME=/var/lib/rabbitmq; /usr/lib/rabbitmq/bin/rabbitmqctl stop"
#Just in case stopping service fails
pkill -u rabbitmq

/usr/sbin/rabbitmq-server
