# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Dependency Manager for PHP"
HOMEPAGE="https://getcomposer.org/"
SRC_URI="https://github.com/composer/composer/releases/download/${PV}/composer.phar -> ${P}.phar"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND=">=dev-lang/php-7.2:*[cli,phar]"

S="${WORKDIR}"

src_unpack() {
	cp "${DISTDIR}/${P}.phar" "${S}/composer.phar" || die
}

src_install() {
	newbin composer.phar composer
}