#!/bin/bash

# Clean rpm locks before puppet run.
# See ticket https://bugs.launchpad.net/fuel/+bug/1339236
rm -f /var/lib/rpm/__db.*
rpm --rebuilddb

puppet apply -v /etc/puppet/modules/nailgun/examples/postgres-only.pp

osmajrel=$(facter operatingsystemmajrelease)
if [ x"$osmajrel" == x"7" ]; then
  PGPORT=5432
  PGDATA=/var/lib/pgsql/data
  su - postgres -c "/usr/bin/pg_ctl stop -D ${PGDATA} -s -m fast"
  su - postgres -c "/usr/bin/postgresql-check-db-dir ${PGDATA}"
  su - postgres -c "/usr/bin/postmaster -D ${PGDATA} -p ${PGPORT}"
elif [ -f '/etc/init.d/postgresql' ]; then
  service postgresql stop
  sudo -u postgres /usr/bin/postmaster -p 5432 -D /var/lib/pgsql/data
else
  pgver=$(rpm -q --queryformat '%{VERSION}' postgresql | cut -c'1-3')
  service "postgresql-${pgver}" stop
  sudo -u postgres "/usr/pgsql-${pgver}/bin/postmaster" -p 5432 -D "/var/lib/pgsql/${pgver}/data"
fi
