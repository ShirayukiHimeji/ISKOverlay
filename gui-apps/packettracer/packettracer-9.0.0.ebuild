# Copyright 2022-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v3

EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="Cisco's packet tracer"
HOMEPAGE="https://www.netacad.com/resources/lab-downloads"
SRC_URI="CiscoPacketTracer_900_Ubuntu_64bit.deb"

S="${WORKDIR}"

LICENSE="Cisco"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="fetch mirror strip"

RDEPEND="
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/icu
	dev-libs/libxml2
	dev-libs/libxslt
	dev-libs/nspr
	dev-libs/nss
	dev-libs/wayland
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	media-libs/libglvnd[X]
	media-libs/libpulse
	sys-apps/dbus
	virtual/udev
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libXtst
	x11-libs/libdrm
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/xcb-util
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-renderutil
	x11-libs/xcb-util-wm
"

QA_PREBUILT="opt/pt/*"

pkg_nofetch(){
	ewarn "To fetch sources, you need a Cisco account which is"
	ewarn "available if you're a web-learning student, instructor"
	ewarn "or you sale Cisco hardware, etc."
	ewarn "after that, go to https://www.netacad.com/resources/lab-downloads and login with"
	ewarn "your account, and after that, you should download a file"
	ewarn "named \"${A}\" then move it to"
	ewarn "your DISTDIR directory"
	ewarn "and then, you can proceed with the installation."
}

src_unpack() {
	# Extract lapisan terluar file .deb (menghasilkan data.tar.xz)
	default

	# Extract isi filesystem aplikasi dari data.tar.xz
	if [[ -f "${WORKDIR}/data.tar.xz" ]]; then
		einfo "Extracting data.tar.xz payload..."
		tar -xf "${WORKDIR}/data.tar.xz" -C "${WORKDIR}" || die
	elif [[ -f "${WORKDIR}/data.tar.gz" ]]; then
		tar -xf "${WORKDIR}/data.tar.gz" -C "${WORKDIR}" || die
	fi

	# (Opsional) Jika di dalam data.tar.xz masih ada AppImage lagi
	local appimage
	appimage=$(find "${WORKDIR}" -type f -name "*.AppImage" 2>/dev/null | head -n 1)
	if [[ -n "${appimage}" ]]; then
		einfo "Extracting internal AppImage..."
		cd "$(dirname "${appimage}")" || die
		chmod +x "${appimage}" || die
		"${appimage}" --appimage-extract >/dev/null || die
		if [[ -d "squashfs-root" ]]; then
			cp -r squashfs-root/* "${WORKDIR}/" || die
		fi
	fi
}

src_install() {
	# Salin struktur direktori ke $ED
	cp -r . "${ED}" || die

	# Cari dan pasang ikon mimetypes secara dinamis jika ditemukan
	local icon_path
	for icon in pka pkt pkz; do
		icon_path=$(find "${WORKDIR}" -type f -name "${icon}.png" 2>/dev/null | head -n 1)
		if [[ -n "${icon_path}" && -f "${icon_path}" ]]; then
			newicon -s 48x48 -c mimetypes "${icon_path}" "application-x-${icon}.png"
		fi
	done

	# Pasang file desktop jika ada
	if [[ -f "${FILESDIR}/${PN}-${PV}.desktop" ]]; then
		newmenu "${FILESDIR}/${PN}-${PV}.desktop" "${PN}.desktop"
	elif [[ -f "${WORKDIR}/usr/share/applications/packettracer-9.0.0.desktop" ]]; then
		newmenu "${WORKDIR}/usr/share/applications/packettracer-9.0.0.desktop" "${PN}.desktop"
	fi

	# Buat symlink executable ke /usr/bin/packettracer jika file opsional terpasang di /opt/pt
	if [[ -f "${ED}/opt/pt/packettracer" ]]; then
		dosym /opt/pt/packettracer /usr/bin/packettracer
	elif [[ -f "${ED}/opt/pt/bin/PacketTracer" ]]; then
		dosym /opt/pt/bin/PacketTracer /usr/bin/packettracer
	fi
}