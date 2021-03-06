# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit distutils-r1 vcs-snapshot

DESCRIPTION="An ordered dictionary with KIO/KVIO"
HOMEPAGE="https://pypi.python.org/pypi/ruamel.ordereddict"
MY_PN="${PN//-/.}"
MY_P="${MY_PN}-${PV}"
SRC_URI="https://bitbucket.org/${MY_PN/.//}/get/${PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

RDEPEND="${PYTHON_DEPS}"

DEPEND="${RDEPEND}
	dev-python/namespace-ruamel[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
	test? ( dev-python/pytest[${PYTHON_USEDEP}] dev-python/flake8[${PYTHON_USEDEP}] )"

S="${WORKDIR}/${MY_P}"

python_install() {
	distutils-r1_python_install --single-version-externally-managed
	find "${ED}" -name '*.pth' -delete || die
}

python_test() {
	py.test -v test/test_py27.py || die
}
