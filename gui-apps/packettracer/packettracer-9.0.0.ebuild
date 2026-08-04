# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v3

EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="Cisco Packet Tracer 9"
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

pkg_nofetch() {
	ewarn "To fetch sources, you need a Cisco account which is"
	ewarn "available if you're a web-learning student, instructor,"
	ewarn "or Cisco partner."
	ewarn "Login to https://www.netacad.com/resources/lab-downloads,"
	ewarn "download \"${A}\", place it into your DISTDIR directory,"
	ewarn "and then rerun emerge."
}

src_unpack() {
	# 1. Unpack arsip utama .deb
	default

	# 2. Extract data.tar.xz ke subfolder khusus 'deb-data'
	mkdir -p "${WORKDIR}/deb-data" || die
	if [[ -f "${WORKDIR}/data.tar.xz" ]]; then
		einfo "Extracting data.tar.xz payload..."
		tar -xf "${WORKDIR}/data.tar.xz" -C "${WORKDIR}/deb-data" || die
	elif [[ -f "${WORKDIR}/data.tar.gz" ]]; then
		einfo "Extracting data.tar.gz payload..."
		tar -xf "${WORKDIR}/data.tar.gz" -C "${WORKDIR}/deb-data" || die
	fi

	# 3. Cari dan extract AppImage jika ada
	local appimage
	appimage=$(find "${WORKDIR}" -type f -name "*.AppImage" 2>/dev/null | head -n 1)

	if [[ -n "${appimage}" ]]; then
		einfo "Internal AppImage found: ${appimage}"
		einfo "Extracting AppImage payload..."
		
		mkdir -p "${WORKDIR}/appimage-extracted" || die
		cd "${WORKDIR}/appimage-extracted" || die
		chmod +x "${appimage}" || die
		"${appimage}" --appimage-extract >/dev/null || die
	fi
}

src_install() {
	# Siapkan direktori tujuan di /opt/pt
	dodir /opt/pt

	# 1. Salin isi AppImage / Debian payload ke /opt/pt
	if [[ -d "${WORKDIR}/appimage-extracted/squashfs-root" ]]; then
		cp -r "${WORKDIR}/appimage-extracted/squashfs-root/"* "${ED}/opt/pt/" || die
	elif [[ -d "${WORKDIR}/deb-data/opt/pt" ]]; then
		cp -r "${WORKDIR}/deb-data/opt/pt/"* "${ED}/opt/pt/" || die
	fi

	# 2. HAPUS file sampah penyebab QA Notice & multilib crash
	rm -rf "${ED}/opt/pt/AppRun" \
	       "${ED}/opt/pt/control.tar.xz" \
	       "${ED}/opt/pt/data.tar.xz" \
	       "${ED}/opt/pt/debian-binary" \
	       "${ED}/opt/pt/DEBIAN" \
	       "${ED}/opt/pt/_gpgorigin" \
	       "${ED}/opt/pt/usr" \
	       "${ED}/opt/pt/lib" \
	       2>/dev/null

	# 3. Ikon mimetype dinamis
	local icon_path
	for icon in pka pkt pkz; do
		icon_path=$(find "${WORKDIR}" -type f -name "${icon}.png" 2>/dev/null | head -n 1)
		if [[ -n "${icon_path}" && -f "${icon_path}" ]]; then
			newicon -s 48x48 -c mimetypes "${icon_path}" "application-x-${icon}.png"
		fi
	done

	# 4. Pasang file desktop dari folder files/pt9.desktop
	if [[ -f "${FILESDIR}/pt9.desktop" ]]; then
		newmenu "${FILESDIR}/pt9.desktop" "${PN}.desktop"
	elif [[ -f "${FILESDIR}/${PN}-${PV}.desktop" ]]; then
		newmenu "${FILESDIR}/${PN}-${PV}.desktop" "${PN}.desktop"
	fi

	# 5. Buat symlink executable ke /usr/bin/packettracer
	if [[ -f "${ED}/opt/pt/packettracer" ]]; then
		dosym /opt/pt/packettracer /usr/bin/packettracer
	elif [[ -f "${ED}/opt/pt/bin/PacketTracer" ]]; then
		dosym /opt/pt/bin/PacketTracer /usr/bin/packettracer
	elif [[ -f "${ED}/opt/pt/packettracer.exe" ]]; then
		# Jaga-jaga jika di dalam opt/pt berupa runner script
		dosym /opt/pt/packettracer.sh /usr/bin/packettracer
	fi
}