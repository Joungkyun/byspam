Summary: The By SPAM is filtering tool for Anti Spam
Summary(ko): 스팸방지를 위한 필터링 툴
Name: byspam
Version: 1.0.4
Release: 1
Epoch: 3
License: BPL
Group: System Environment/Daemons
URL: http://svn.oops.org/wsvn/OOPS.byspam
Source0: ftp://ftp.oops.org/pub/oops/byspam/%{name}-%{version}.tar.bz2
BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Requires: procmail, perl
BuildArchitectures: noarch

Packager: JoungKyun. Kim <http://oops.org>
Vendor:   OOPS.org

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

if test ! -f %{_sysconfdir}/mail/procmailrc ; then
  if test ! -d %{_sysconfdir}/mail; then
    mkdir -p %{_sysconfdir}/mail
    touch %{_sysconfdir}/mail/byspam-make
  fi
  touch %{_sysconfdir}/mail/procmailrc
  touch %{_sysconfdir}/mail/procmailrc-byspam
fi


./configure --prefix=/usr \
	--bindir=%{_bindir} \
	--sysconfdir=%{_sysconfdir}/byspam \
	--includedir=%{_includedir}/byspam \
	--with-filter=%{_sysconfdir}/byspam/Filter \
	--with-perl=%{_bindir}/perl \
	--with-procrc=%{_sysconfdir}/procmailrc

if test -f %{_sysconfdir}/mail/byspam-make; then
  rm -rf %{_sysconfdir}/mail
elif test -f %{_sysconfdir}/mail/procmailrc-byspam ; then
  rm -f %{_sysconfdir}/mail/procmailrc-byspam
  rm -f %{_sysconfdir}/mail/procmailrc
fi

make

%install
if [ -d %{buildroot} ]; then
  rm -rf %{buildroot}
fi
mkdir -p %{buildroot}

make DESTDIR=%{buildroot} install

pushd %{buildroot}%{_sysconfdir}/byspam &> /dev/null
mv -f byspam.conf.ko byspam.conf
popd &> /dev/null

%{__mkdir_p} %{buildroot}%{_sysconfdir}/sysconfig
%{__install} -m644 etc/byspamcron.sysconfig %{buildroot}%{_sysconfdir}/sysconfig/byspamcron

%post
if [ -f %{_sysconfdir}/procmailrc ]; then
  PROCRCCHK=$(grep "^INCLUDERC=.\+\/filter\.rc" %{_sysconfdir}/procmailrc)
  if [ -z "${PROCRCCHK}" ]; then
    echo "SAFE_INCLUDERC=%{_sysconfdir}/byspam/filter.rc" >> %{_sysconfdir}/procmailrc
  else
    if [ -f %{_bindir}/perl ]; then
      perl -pi -e "s/INCLUDERC=/SAFE_INCLUDERC/g" %{_sysconfdir}/procmailrc
    else
      sed -e "s/INCLUDERC=/SAFE_INCLUDERC/g" %{_sysconfdir}/procmailrc > /tmp/byspatmprc
      mv -f /tmp/byspatmprc %{_sysconfdir}/procmailrc
    fi
  fi
fi

if [ -f %{_sysconfdir}/mail/procmailrc ]; then
  PROCRCCHK=$(grep "^SAFE_INCLUDERC=.\+\/filter\.rc" %{_sysconfdir}/mail/procmailrc)
  if [ -z "${PROCRCCHK}" ]; then
    echo "SAFE_INCLUDERC=%{_sysconfdir}/byspam/filter.rc" >> %{_sysconfdir}/procmailrc
  fi
fi


%preun
if [ $1 = 0 ]; then
  LCHK=$(echo ${LANG} | egrep ko)
  if [ -n "${LCHK}" ]; then
    echo "-Uhv 옵션을 이용하여 byspam rpm 패키지를 업데이트 하는"
    echo "중이라면 아래의 메세지를 무시하고 smtp 데몬을 재시작 하십시오."
    echo
    echo "%{_sysconfdir}/procmailrc 에서 \"INCLUDERC=%{_sysconfdir}/byspam/filter.rc\""
    echo "라인을 삭제 하시고 smtp 데몬을 재시작 하십시오"
  else
    echo "If you use -Uhv option to upgrade byspam rpm package,"
    echo "ignored follow message and smtp restart"
    echo
    echo "Pleas manualy removed \"INCLUDERC=%{_sysconfdir}/byspam/filter.rc\""
    echo "in %{_sysconfdir}/procmailrc and, restart smtp daemon"
  fi
fi

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root)
%dir %{_sysconfdir}/byspam
%config(noreplace) %{_sysconfdir}/byspam/Filter/filter-allow
%config(noreplace) %{_sysconfdir}/byspam/Filter/filter-body
%config(noreplace) %{_sysconfdir}/byspam/Filter/filter-date
%config(noreplace) %{_sysconfdir}/byspam/Filter/filter-extra
%config(noreplace) %{_sysconfdir}/byspam/Filter/filter-from
%config(noreplace) %{_sysconfdir}/byspam/Filter/filter-ignore
%config(noreplace) %{_sysconfdir}/byspam/Filter/filter-subject
%config(noreplace) %{_sysconfdir}/byspam/Filter/filter-to
%config(noreplace) %{_sysconfdir}/byspam/byspam.conf
%config(noreplace) %{_sysconfdir}/byspam/filter.rc
%config(noreplace) %{_sysconfdir}/sysconfig/byspamcron
%attr(644,root,root) %{_sysconfdir}/cron.d/byspam
%attr(755,root,root) %{_bindir}/byspamFilter
%attr(755,root,root) %{_bindir}/byspamClear
%attr(755,root,root) %{_bindir}/byspamReload
%attr(755,root,root) %{_bindir}/byspamTrash
%attr(755,root,root) %{_bindir}/byspamTrashMgr
%attr(755,root,root) %{_bindir}/byspamPlain
%attr(755,root,root) %{_bindir}/byspamRegexChk
%dir %{_includedir}/byspam
%{_includedir}/byspam/Byspam/Common.pm
%{_includedir}/byspam/Byspam/Encode.pm
%{_includedir}/byspam/Byspam/Getopt.pm
%{_includedir}/byspam/Byspam/Init.pm
%{_includedir}/byspam/Byspam/Mail.pm
%{_includedir}/byspam/Byspam/Parse.pm
%{_includedir}/byspam/Byspam/Trash.pm

%doc Changelog ENVIRONMENT LICENSE README INSTALL REGEX

%changelog
* Sun Apr 27 2013 JoungKyun.Kim <http://oops.org> 3:1.0.3-1
- update 1.0.3

* Mon Oct 24 2005 JoungKyun Kim <http://oops.org> 3:1.0.2-1
- update 1.0.2

* Tue Feb  1 2005 JoungKyun Kim <http://oops.org> 2:1.0.1-1
- update 1.0.1

* Tue Dec 07 2004 JoungKyun Kim <http://oops.org> 1:1.0.0-1
- update 1.0.0

* Tue Apr 06 2004 JoungKyun Kim <http://oops.org> 0.2.3-1
- update 0.2.4

* Wed Jun 11 2003 JoungKyun Kim <http://oops.org> 0.2.3-1
- update 0.2.3

* Mon Oct 14 2002 2002 JoungKyun Kim <http://oops.org> 0.2.2-2
- fixed byspamTrash if exists similar account name

* Tue Jul 16 2002 JoungKyun Kim <http://oops.org>
- update 0.2.2

* Thu Jun 27 2002 JoungKyun Kim <http://oops.org>
- update 0.2.1

* Thu Jun 27 2002 JoungKyun Kim <http://oops.org>
- update 0.2.0

* Wed Apr 10 2002 JoungKyun Kim <http://oops.org>
- minor updated 0.1.4

* Mon Apr 08 2002 JoungKyun Kim <http://oops.org>
- updated 0.1.4

* Thu Apr 04 2002 JoungKyun Kim <http://oops.org>
- updated 0.1.3

* Tue Apr 02 2002 JoungKyun Kim <http://oops.org>
- updated 0.1.2

* Mon Mar 25 2002 JoungKyun Kim <http://oops.org>
- packaged by spam in RH 6.2

