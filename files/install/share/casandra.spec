# Copyright (c) 2009, Jataka-Sources
# All rights reserved.
#
%define _topdir	 	${basedir}/target	 
%define buildroot   %{_topdir}/%{name}-%{version}-root
%define _sourcedir  %{_topdir}
%define __jar_repack 0
%global username cassandra

Name:		apache-cassandra
Version:	${version}
Release:	${buildNumber}.%{osVerTag}
Summary:	The Apache Cassandra Project develops a highly scalable second-generation distributed database.
License:	Apache License

Group:		Applications/NO-SQL
Source0:	apache-cassandra-${version}-bin.tar.gz
Source1:	cassandra-rpm-${version}.tar.gz
Packager:	Yaniv Marom-Nachumi <yaniv@jataka-sources.org>
Vendor:		Jataka Sources
URL:		http://www.jataka-sources.net
BuildRoot:	%{buildroot}
BuildArch:	noarch

Requires:      java >= 1.6.0
Requires:      jpackage-utils
Requires(pre): user(cassandra)
Requires(pre): group(cassandra)
Requires(pre): shadow-utils
Provides:      user(cassandra)
Provides:      group(cassandra)

%description
The Apache Cassandra Project develops a highly scalable second-generation distributed database.
 
%prep
rm -rf "${RPM_BUILD_ROOT}"
%setup -b 0 -T -n apache-cassandra-${version}
%setup -b 1 -T -n cassandra-rpm-${version}

%install
DESTDIR="${RPM_BUILD_ROOT}" \
	./install.sh --init-scripts

%clean
rm -rf "${RPM_BUILD_ROOT}"

%pre
getent group %{username} >/dev/null || groupadd -r %{username}
getent passwd %{username} >/dev/null || \
useradd -d /usr/share/%{username} -g %{username} -M -r %{username}
exit 0

%preun
# only delete user on removal, not upgrade
if [ "$1" = "0" ]; then
    userdel %{username}
fi
  
%files
%defattr(-,root,root,0755)
#%attr(755,root,root) %{_bindir}/*
#%attr(755,root,root) %{_sbindir}/cassandra
%attr(755,root,root) /etc/init.d/%{username}
%attr(755,root,root) /etc/default/%{username}
%attr(755,root,root) /etc/security/limits.d/%{username}.conf
%attr(755,root,root) /%{_sysconfdir}/logrotate.d/%{username}*
%attr(755,root,root) %config /%{_sysconfdir}/sysconfig/%{username}*

%attr(755,%{username},%{username}) /usr/share/%{username}*
%attr(755,%{username},%{username}) /usr/share/doc/%{username}*
%attr(755,%{username},%{username}) %config(noreplace) /%{_sysconfdir}/%{username}
%attr(755,%{username},%{username}) %config(noreplace) /var/lib/%{username}/*
%attr(755,%{username},%{username}) /var/log/%{username}*
%attr(755,%{username},%{username}) /var/run/%{username}*

%post
alternatives --install /etc/%{username}/conf %{username} /etc/%{username}/default.conf/ 0
exit 0

%postun
# only delete alternative on removal, not upgrade
if [ "$1" = "0" ]; then
    alternatives --remove %{username} /etc/%{username}/default.conf/
fi
exit 0

%changelog
