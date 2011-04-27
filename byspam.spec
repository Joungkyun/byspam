Summary: The By SPAM is filtering tool for Anti Spam
Summary(ko): ���Թ����� ���� ���͸� ��
Name: byspam
Version: 1.0.2
Release: 1
Epoch: 3
Copyright: BPL
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
	--sysconfdir=/etc/byspam \
	--includedir=/usr/include/byspam \
	--with-filter=/etc/byspam/Filter \
	--with-perl=/usr/bin/perl \
	--with-procrc=/etc/procmailrc

make

%install
if [ -d $RPM_BUILD_ROOT ]; then
  rm -rf $RPM_BUILD_ROOT
fi
mkdir -p $RPM_BUILD_ROOT

make DESTDIR=$RPM_BUILD_ROOT install

pushd $RPM_BUILD_ROOT/etc/byspam &> /dev/null
mv -f byspam.conf.ko byspam.conf
popd &> /dev/null

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
%attr(755,root,root) /etc/cron.d/byspam  
%attr(755,root,root) /usr/bin/byspamFilter   
%attr(755,root,root) /usr/bin/byspamClear
%attr(755,root,root) /usr/bin/byspamReload
%attr(755,root,root) /usr/bin/byspamTrash    
%attr(755,root,root) /usr/bin/byspamTrashMgr
%attr(755,root,root) /usr/bin/byspamPlain
%attr(755,root,root) /usr/bin/byspamRegexChk
%dir /usr/include/byspam
/usr/include/byspam/Byspam/Common.pm
/usr/include/byspam/Byspam/Encode.pm
/usr/include/byspam/Byspam/Getopt.pm
/usr/include/byspam/Byspam/Init.pm
/usr/include/byspam/Byspam/Mail.pm
/usr/include/byspam/Byspam/Parse.pm
/usr/include/byspam/Byspam/Trash.pm

%doc Changelog ENVIRONMENT LICENSE README INSTALL REGEX

%changelog
* Mon OCt 24 2005 JoungKyun Kim <http://www.oops.org> 3:1.0.2-1
- update 1.0.1

* Tue Feb  1 2005 JoungKyun Kim <http://www.oops.org> 2:1.0.1-1
- update 1.0.1

* Tue Dec 07 2004 JoungKyun Kim <http://www.oops.org> 1:1.0.0-1
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

