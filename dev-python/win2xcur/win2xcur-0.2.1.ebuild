EAPI=8

DIGEST_SOURCES="yes"
PYTHON_COMPAT=( python{3_11,3_12,3_13,3_14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 pypi

DESCRIPTION="win2xcur is a tool to convert Windows .cur and .ani cursors to Xcursor format, and vice versa."

HOMEPAGE="https://github.com/quantum5/win2xcur"
LICENSE="GPL-3.0"
SRC_URI="https://github.com/quantum5/win2xcur/releases/download/v${PV}/${PN}-${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="test"

SLOT="0"
KEYWORDS="~amd64"

IUSE=""
DEPENDENCIES="dev-python/numpy[${PYTHON_USEDEP}]
	     dev-python/wand[${PYTHON_USEDEP}]
	    "
BDEPEND="${DEPENDENCIES}"
RDEPEND="${DEPENDENCIES}"
