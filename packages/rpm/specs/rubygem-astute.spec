%define rbname astute
%define version 6.0.0
%define release 1
%global gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%global geminstdir %{gemdir}/gems/%{gemname}-%{version}
%define gembuilddir %{buildroot}%{gemdir}

Summary: Orchestrator for OpenStack deployment
Name: rubygem-%{rbname}

Version: %{version}
Release: %{release}
Group: Development/Ruby
License: Distributable
URL: http://fuel.mirantis.com
Source0: %{rbname}-%{version}.gem
# Make sure the spec template is included in the SRPM
Source1: astute.conf
BuildRoot: %{_tmppath}/%{name}-%{version}-root
Requires: ruby
Requires: rubygem-activesupport
Requires: mcollective-client
Requires: rubygem-mcollective-client
Requires: rubygem-symboltable
Requires: rubygem-rest-client
Requires: rubygem-popen4
Requires: rubygem-amqp
Requires: rubygem-raemon
Requires: rubygem-net-ssh
Requires: rubygem-net-ssh-gateway
Requires: rubygem-net-ssh-multi
Requires: openssh-clients
BuildRequires: ruby
BuildArch: noarch
Provides: rubygem(Astute) = %{version}


%description
Deployment Orchestrator of Puppet via MCollective. Works as a library or from
CLI.


%prep
%setup -T -c

%build

%install
%{__rm} -rf %{buildroot}
mkdir -p %{gembuilddir}
gem install --local --install-dir %{gembuilddir} --force %{SOURCE0}
mkdir -p %{buildroot}%{_bindir}
mv %{gembuilddir}/bin/* %{buildroot}%{_bindir}
rmdir %{gembuilddir}/bin

install -d -m 750 %{buildroot}%{_sysconfdir}/astute
install -p -D -m 640 %{SOURCE1} %{buildroot}%{_sysconfdir}/astute/astute.conf
cat > %{buildroot}%{_bindir}/astuted <<EOF
#!/bin/bash
ruby -r 'rubygems' -e "gem 'astute', '>= 0'; load Gem.bin_path('astute', 'astuted', '>= 0')" -- \$@
EOF

install -d -m 755 %{buildroot}%{_localstatedir}/log/astute

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root)
%{gemdir}/gems/%{rbname}-%{version}/bin/*
%{gemdir}/gems/%{rbname}-%{version}/lib/*
%{gemdir}/gems/%{rbname}-%{version}/spec/*
%{gemdir}/gems/%{rbname}-%{version}/examples/*

%dir %attr(0750, naily, naily) %{_sysconfdir}/%{rbname}
%config(noreplace) %attr(0640, root, naily) %{_sysconfdir}/%{rbname}/astute.conf
%dir %attr(0755, naily, naily) %{_localstatedir}/log/%{rbname}
%config(noreplace) %{_bindir}/astuted

%doc %{gemdir}/doc/astute-6.0.0
%{gemdir}/cache/astute-6.0.0.gem
%{gemdir}/specifications/astute-6.0.0.gemspec

%changelog
