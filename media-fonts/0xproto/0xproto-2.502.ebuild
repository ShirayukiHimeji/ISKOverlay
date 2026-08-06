# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="0xProto font family"
HOMEPAGE="https://github.com/0xType/0xProto"
UNDER_PV=$(ver_rs 1- '_' ${PV})
SRC_URI="https://github.com/0xType/0xProto/releases/download/${PV}/0xProto_${UNDER_PV}.zip -> ${P}.zip"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS=""
IUSE=""

BDEPEND="app-arch/unzip"

S="${WORKDIR}"

src_install() {
    insinto /usr/share/fonts/0xproto
    doins -r fonts/*
}

pkg_postinst() {
    fc-cache -f >/dev/null 2>&1 || true
}

pkg_postrm() {
    fc-cache -f >/dev/null 2>&1 || true
}
