#!/bin/bash -xe

# Clean rpm locks before puppet run.
# See ticket https://bugs.launchpad.net/fuel/+bug/1339236
rm -f /var/lib/rpm/__db.*
rpm --rebuilddb

#Workaround for facter to detect docker
grep -q '/system.slice/dock' /proc/1/cgroup && sed -i 's/\/docker\//\/system\.slice\/docker/' /usr/share/ruby/vendor_ruby/facter/util/virtual.rb

exitcode=0
puppet apply --detailed-exitcodes -v /etc/puppet/modules/nailgun/examples/keystone-only.pp || exitcode=$?
if [[ $exitcode != 0 && $exitcode != 2 ]]; then
  echo Puppet apply failed with exit code: $exitcode
  exit $exitcode
fi

pkill keystone-all
keystone-all
