# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v3

EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="Cisco Packet Tracer 9.0.0"
HOMEPAGE="https://www.netacad.com/resources/lab-downloads"
SRC_URI="CiscoPacketTracer_900_Ubuntu_64bit.deb"

S="${WORKDIR}"

LICENSE="Cisco"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="fetch mirror strip"

# Basic runtime dependencies required by the AppImage and setup scripts
RDEPEND="
	sys-fs/fuse:3
"

QA_PREBUILT="opt/pt/*"

pkg_nofetch() {
	ewarn "To fetch sources, you need a Cisco account which is"
	ewarn "available if you're a web-learning student, instructor,"
	ewarn "or Cisco partner."
	ewarn "Login to https://www.netacad.com/resources/lab-downloads,"
	ewarn "download \"${A}\", place it into your DISTDIR directory,"
	ewarn "and then rerun emerge."
}

src_unpack() {
	default

	# Unpack the inner data.tar.xz archive into the payload directory
	mkdir -p "${WORKDIR}/payload" || die
	if [[ -f "${WORKDIR}/data.tar.xz" ]]; then
		einfo "Extracting data.tar.xz..."
		tar -xf "${WORKDIR}/data.tar.xz" -C "${WORKDIR}/payload" || die
	elif [[ -f "${WORKDIR}/data.tar.gz" ]]; then
		einfo "Extracting data.tar.gz..."
		tar -xf "${WORKDIR}/data.tar.gz" -C "${WORKDIR}/payload" || die
	fi
}

src_install() {
	dodir /opt/pt

	# 1. Copy the entire /opt/pt structure or extracted payload to /opt/pt/ inside $ED
	if [[ -d "${WORKDIR}/payload/opt/pt" ]]; then
		cp -rp "${WORKDIR}/payload/opt/pt/"* "${ED}/opt/pt/" || die
	else
		cp -rp "${WORKDIR}/payload/"* "${ED}/opt/pt/" || die
	fi

	# Grant executable permissions (+x) to all EULA AppImages
	chmod -R +x "${ED}/opt/pt"

	# 2. CREATE EXECUTABLE SYMLINK
	# Prioritize runner/EULA management scripts, then AppImage binaries
	if [[ -f "${ED}/opt/pt/packettracer.AppImage" ]]; then
		dosym /opt/pt/packettracer.AppImage /usr/bin/packettracer
	fi


}

pkg_postinst() {
    xdg_pkg_postinst

    elog ""
    elog "Cisco Packet Tracer 9.0.0 Installation Notes:"
    elog ""
    elog "First launch:"
    elog "  packettracer"
    elog ""
    elog "If you have already accepted the EULA but the desktop"
    elog "entry does not appear, run:"
    elog "  packettracer --pt-deactivate"
    elog "  packettracer --pt-activate"
    elog ""
    elog "If this is your first activation, it is safe to ignore"
    elog "any errors from '--pt-deactivate'."
    elog ""
    elog "Before uninstalling Packet Tracer, run:"
    elog "  packettracer --pt-deactivate"
}

pkg_postrm() {
    ewarn ""
    ewarn "Packet Tracer desktop integration is per-user."
    ewarn ""
    ewarn "If menu entries remain after uninstall, remove:"
    ewarn "  CiscoPacketTracer*.desktop"
    ewarn "from ~/.local/share/applications/"
    ewarn ""
    ewarn "and remove Packet Tracer icons from:"
    ewarn "  ~/.local/share/icons/"
}