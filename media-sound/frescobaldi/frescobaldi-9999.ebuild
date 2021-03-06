# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{2,3,4,5,6} )

inherit distutils-r1 gnome2-utils git-r3

DESCRIPTION="A LilyPond sheet music text editor"
HOMEPAGE="http://www.frescobaldi.org/"
EGIT_REPO_URI="https://github.com/wbsoft/${PN}.git"

LICENSE="GPL-2 public-domain" # public-domain is for bundled Tango icons
SLOT="0"
KEYWORDS=""
IUSE="portmidi"

RDEPEND="
	dev-python/PyQt5[svg,${PYTHON_USEDEP}]
	dev-python/python-poppler-qt5[${PYTHON_USEDEP}]
	>=dev-python/python-ly-0.9.4[${PYTHON_USEDEP}]
	>=media-sound/lilypond-2.14.2
	portmidi? ( media-libs/portmidi )"
DEPEND="${RDEPEND}"

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
