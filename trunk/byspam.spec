Summary: The By SPAM is filtering tool for Anti Spam
Summary(ko): 스팸방지를 위한 필터링 툴
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
By SPAM 은 smtp 데몬과 procmail 과 연동하여 스팸메일을 필터링 하기위한 도구
이다. 이 프로그램은 펄로 작성이 되어졌으며, 펄의 정규표현식을 이용하여 강력
한 필터링을 제공한다. 또한, BASE64, QUOTED-PRINTABLE 인코딩을 디코딩하여 필
터링을 한다.

%prep
%setup -q

./configure --prefix=/usr \
	--bindir=/usr/bin \
	--confdir=/etc/byspam \
	--includedir=/usr/include/byspam \
	--with-filter=/etc/byspam/Filter \
	--with-perl=/usr/bin/perl \
	--with-procpc=/etc/procmailrc

make

%install
if [ -d $RPM_BUILD_ROOT ]; then
  rm -rf $RPM_BUILD_ROOT
fi
mkdir -p $RPM_BUILD_ROOT

make DESTDIR=$RPM_BUILD_ROOT install

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
    echo "-Uhv 옵션을 이용하여 byspam rpm 패키지를 업데이트 하는"
    echo "중이라면 아래의 메세지를 무시하고 smtp 데몬을 재시작 하십시오."
    echo
    echo "/etc/procmailrc 에서 \"INCLUDERC=/etc/byspam/filter.rc\""
    echo "라인을 삭제 하시고 smtp 데몬을 재시작 하십시오"
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
%attr(644,root,root) /etc/cron.d/byspam
%attr(755,root,root) /usr/bin/byspamFilter
%attr(755,root,root) /usr/bin/byspamClear
%attr(755,root,root) /usr/bin/byspamReload
%attr(755,root,root) /usr/bin/byspamTrash
%attr(755,root,root) /usr/bin/byspamTrashMgr
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

