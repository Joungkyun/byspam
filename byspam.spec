Summary: The By SPAM is filtering tool for Anti Spam
Summary(ko): ���Թ����� ���� ���͸� ��
Name: byspam
Version: 1.0.0
Release: 1
Copyright: GPL
Group: System Environment/Daemons
URL: http://cvs.oops.org/cgi-bin/oopsdev.cgi/byspam/
Source0: ftp://ftp.oops.org/pub/Linux/OOPS/Source/byspam/%{name}-%{version}.tar.bz2
BuildRoot: /var/tmp/%{name}-root
Requires: procmail, perl
BuildArchitectures: noarch

Packager: JoungKyun. Kim <http://www.oops.org>
Vendor:   OOPS Development ORG

%description
The By SPAM is filtering tool for anti spam with smtp daemon and procmail
This program is built in perl and filtering wiht regular expression of perl.
And supproted BASE64, QUOTED-PRINTABLE encoding

%description -l ko
By SPAM �� smtp ����� procmail �� �����Ͽ� ���Ը����� ���͸� �ϱ����� ����
�̴�. �� ���α׷��� �޷� �ۼ��� �Ǿ�������, ���� ����ǥ������ �̿��Ͽ� ����
�� ���͸��� �����Ѵ�. ����, BASE64, QUOTED-PRINTABLE ���ڵ��� ���ڵ��Ͽ� ��
�͸��� �Ѵ�.

%prep
%setup -q

./configure --prefix=/usr \
	--bindir=/usr/bin \
	--confdir=/etc/byspam \
	--filterdir=/etc/byspam/Filter \
	--includedir=/usr/include/byspam \
	--perlpath=/usr/bin/perl \
	--procpath=/etc/procmailrc \
	--package=1


%install
if [ -d $RPM_BUILD_ROOT ]; then
  rm -rf $RPM_BUILD_ROOT
fi
mkdir -p $RPM_BUILD_ROOT

DESTDIR=$RPM_BUILD_ROOT ./install

%post
if [ $1 = 0 ]; then
  PROCRCCHK=$(egrep "^INCLUDERC=.+\/filter\.rc" /etc/procmailrc)
  if [ -z "${PROCRCCHK}" ]; then
    echo "INCLUDERC=/etc/byspam/filter.rc" >> /etc/procmailrc
  fi
fi

%preun
if [ $1 = 0 ]; then
  LCHK=$(echo ${LANG} | egrep ko)
  if [ -n "${LCHK}" ]; then
    echo "-Uhv �ɼ��� �̿��Ͽ� byspam rpm ��Ű���� ������Ʈ �ϴ�"
    echo "���̶�� �Ʒ��� �޼����� �����ϰ� smtp ������ ����� �Ͻʽÿ�."
    echo
    echo "/etc/procmailrc ���� \"INCLUDERC=/etc/byspam/filter.rc\""
    echo "������ ���� �Ͻð� smtp ������ ����� �Ͻʽÿ�"
  else
    echo "If you use -Uhv option to upgrade byspam rpm package,"
    echo "ignored follow message and smtp restart"
    echo
    echo "Pleas manualy removed \"INCLUDERC=/etc/byspam/filter.rc\""
    echo "in /etc/procmailrc and, restart smtp daemon"
  fi
fi

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%dir /etc/byspam
#/etc/byspam/Filter
%config(noreplace) /etc/byspam/Filter/filter-allow
%config(noreplace) /etc/byspam/Filter/filter-body
%config(noreplace) /etc/byspam/Filter/filter-date            
%config(noreplace) /etc/byspam/Filter/filter-extra           
%config(noreplace) /etc/byspam/Filter/filter-from
%config(noreplace) /etc/byspam/Filter/filter-ignore          
%config(noreplace) /etc/byspam/Filter/filter-subject        
%config(noreplace) /etc/byspam/Filter/filter-to              
%config(noreplace) /etc/byspam/byspam.conf 
%config(noreplace) /etc/byspam/filter.rc   
%attr(755,root,root) /etc/cron.daily/byspam  
%attr(755,root,root) /usr/bin/byspamFilter   
%attr(755,root,root) /usr/bin/byspamTrash    
%attr(755,root,root) /usr/bin/byspamPlain
%attr(755,root,root) /usr/bin/byspamRegexChk
%dir /usr/include/byspam
/usr/include/byspam/Byspam/*.pm

%doc Changelog ENVIRONMENT LICENSE README

%changelog
* Wed Dec 01 2004 JoungKyun Kim <http://www.oopw.org> 1.0.0-1
- update 1.0.0

* Tue Apr 06 2004 JoungKyun Kim <http://www.oops.org> 0.2.3-1
- update 0.2.4

* Wed Jun 11 2003 JoungKyun Kim <http://www.oops.org> 0.2.3-1
- update 0.2.3

* Mon Oct 14 2002 2002 JoungKyun Kim <http://www.oops.org> 0.2.2-2
- fixed byspamTrash if exists similar account name

* Tue Jul 16 2002 JoungKyun Kim <http://www.oops.org>
- update 0.2.2

* Thu Jun 27 2002 JoungKyun Kim <http://www.oops.org>
- update 0.2.1

* Thu Jun 27 2002 JoungKyun Kim <http://www.oops.org>
- update 0.2.0

* Wed Apr 10 2002 JoungKyun Kim <http://www.oops.org>
- minor updated 0.1.4

* Mon Apr 08 2002 JoungKyun Kim <http://www.oops.org>
- updated 0.1.4

* Thu Apr 04 2002 JoungKyun Kim <http://www.oops.org>
- updated 0.1.3

* Tue Apr 02 2002 JoungKyun Kim <http://www.oops.org>
- updated 0.1.2

* Mon Mar 25 2002 JoungKyun Kim <http://www.oops.org>
- packaged by spam in RH 6.2

