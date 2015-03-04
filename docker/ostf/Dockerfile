# fuel/ostf
#
# Version     0.1

FROM eayunstack-fuel
MAINTAINER Matthew Mosesohn mmosesohn@mirantis.com

#RUN rm -rf /etc/yum.repos.d/*;echo -e "[nailgun]\nname=Nailgun Local Repo\nbaseurl=http://$(ip route show to exact 0.0.0.0/0 | awk '{ print $3 }'):_PORT_/os/x86_64/\ngpgcheck=0" > /etc/yum.repos.d/nailgun.repo;yum clean all; yum --quiet install -y python-fuelclient supervisor postgresql-libs
RUN rm -rf /etc/yum.repos.d/*;echo -e "[nailgun]\nname=Nailgun Local Repo\nbaseurl=http://192.168.3.239/testing/fuel/local_mirror/centos/os/x86_64/\ngpgcheck=0" > /etc/yum.repos.d/nailgun.repo;yum clean all; yum --quiet install -y python-fuelclient supervisor postgresql-libs

ADD etc /etc
ADD start.sh /usr/local/bin/start.sh

RUN mkdir -p /var/run/lock/subsys
RUN puppet apply --detailed-exitcodes -d -v /etc/puppet/modules/nailgun/examples/ostf-only.pp; [[ $? == 0 || $? == 2 ]]

RUN echo -e "[nailgun]\nname=Nailgun Local Repo\nbaseurl=file:/var/www/nailgun/centos/x86_64\ngpgcheck=0" > /etc/yum.repos.d/nailgun.repo; yum clean all; chmod +x /usr/local/bin/start.sh

EXPOSE 8777
CMD /usr/local/bin/start.sh
