# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="0xProto nerd fonts family"
HOMEPAGE="https://github.com/ryanoasis/nerd-fonts"
SRC_URI="https://github.com/ryanoasis/nerd-fonts/releases/download/v${PV}/0xProto.zip -> ${P}.zip"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS=""
IUSE=""

BDEPEND="app-arch/unzip"

S="${WORKDIR}"

FONT_SUFFIX="ttf"
