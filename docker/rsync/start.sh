#!/bin/bash -e

# Clean rpm locks before puppet run.
# See ticket https://bugs.launchpad.net/fuel/+bug/1339236
rm -f /var/lib/rpm/__db.*
rpm --rebuilddb

pkill xinetd || echo "no xinetd process"
/usr/sbin/xinetd -dontfork
