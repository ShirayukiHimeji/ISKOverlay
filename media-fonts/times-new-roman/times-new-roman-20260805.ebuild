
# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Times New Roman family"
HOMEPAGE="https://github.com/ShirayukiHimeji/Myfonts"
SRC_URI="https://github.com/ShirayukiHimeji/Myfonts/releases/download/20260805/TimesNewRoman.zip -> ${P}.zip"

LICENSE="mscorefonts"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

BDEPEND="app-arch/unzip"

S="${WORKDIR}"


FONT_S="${S}/TimesNewRoman"
FONT_SUFFIX="ttf"
