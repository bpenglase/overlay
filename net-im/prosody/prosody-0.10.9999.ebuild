# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit flag-o-matic multilib systemd versionator mercurial

DESCRIPTION="Prosody is a flexible communications server for Jabber/XMPP written in Lua"
HOMEPAGE="http://prosody.im/"
EHG_REPO_URI="http://hg.prosody.im/0.10"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="ipv6 libevent mysql postgres sqlite ssl zlib jit"

DEPEND="
	net-im/jabber-base
	!jit? ( dev-lang/lua:0 )
	jit? ( dev-lang/luajit:2 )
	>=net-dns/libidn-1.1
	dev-libs/openssl:*
"
RDEPEND="
	${DEPEND}
	>=dev-lua/luaexpat-1.3.0
	dev-lua/luafilesystem
	ipv6? ( >=dev-lua/luasocket-3 )
	!ipv6? ( dev-lua/luasocket )
	libevent? ( >=dev-lua/luaevent-0.4.3 )
	mysql? ( dev-lua/luadbi[mysql] )
	postgres? ( dev-lua/luadbi[postgres] )
	sqlite? ( dev-lua/luadbi[sqlite] )
	ssl? ( dev-lua/luasec )
	zlib? ( dev-lua/lua-zlib )
"

JABBER_ETC="/etc/jabber"
JABBER_SPOOL="/var/spool/jabber"

src_prepare() {
	epatch "${FILESDIR}/${PN}-0.10-cfg.lua.patch"
	sed -i -e "s!MODULES = \$(DESTDIR)\$(PREFIX)/lib/!MODULES = \$(DESTDIR)\$(PREFIX)/$(get_libdir)/!"\
		-e "s!SOURCE = \$(DESTDIR)\$(PREFIX)/lib/!SOURCE = \$(DESTDIR)\$(PREFIX)/$(get_libdir)/!"\
		-e "s!INSTALLEDSOURCE = \$(PREFIX)/lib/!INSTALLEDSOURCE = \$(PREFIX)/$(get_libdir)/!"\
		-e "s!INSTALLEDMODULES = \$(PREFIX)/lib/!INSTALLEDMODULES = \$(PREFIX)/$(get_libdir)/!"\
		 Makefile || die
}

src_configure() {
	# the configure script is handcrafted (and yells at unknown options)
	# hence do not use 'econf'
	append-cflags -D_GNU_SOURCE
	luajit=""
	if use jit; then
		luajit="--runwith=luajit"
	fi
	./configure \
		--ostype=linux $luajit \
		--prefix="/usr" \
		--sysconfdir="${JABBER_ETC}" \
		--datadir="${JABBER_SPOOL}" \
		--with-lua-include=/usr/include \
		--with-lua-lib=/usr/$(get_libdir)/lua \
		--cflags="${CFLAGS} -Wall -fPIC" \
		--ldflags="${LDFLAGS} -shared" \
		--c-compiler="$(tc-getCC)" \
		--linker="$(tc-getCC)" \
		--require-config || die "configure failed"
}

src_install() {
	emake DESTDIR="${D}" install
	systemd_dounit "${FILESDIR}/${PN}".service
	systemd_newtmpfilesd "${FILESDIR}/${PN}".tmpfilesd "${PN}".conf
	newinitd "${FILESDIR}/${PN}".initd-r2 ${PN}
}

src_test() {
	cd tests || die
	./run_tests.sh || die
}
