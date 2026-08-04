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
KEYWORDS="amd64"
RESTRICT="fetch mirror strip"

# Basic runtime dependencies required by the AppImage and setup scripts
RDEPEND="
	sys-fs/fuse:2
	dev-libs/glib:2
	x11-libs/libX11
	media-libs/alsa-lib
	sys-libs/zlib
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

	# Grant executable permissions (+x) to all EULA scripts, binaries, and AppImages
	chmod -R +x "${ED}/opt/pt"

	# 2. DETECT & INSTALL DESKTOP LAUNCHER
	local upstream_desktop
	# Look for an upstream .desktop file inside the extracted package
	upstream_desktop=$(find "${ED}/opt/pt" -maxdepth 2 -type f -name "*.desktop" | head -n 1)

	if [[ -n "${upstream_desktop}" && -f "${upstream_desktop}" ]]; then
		einfo "Found upstream desktop file: ${upstream_desktop##*/}"
		
		# Patch the Exec path to point to /usr/bin/packettracer
		sed -i 's|^Exec=.*|Exec=/usr/bin/packettracer %f|g' "${upstream_desktop}"
		
		# Install upstream .desktop as packettracer.desktop
		newmenu "${upstream_desktop}" "${PN}.desktop"
	elif [[ -f "${FILESDIR}/pt9.desktop" ]]; then
		einfo "Using custom fallback desktop file from files/packettracer-9.0.0.desktop"
		newmenu "${FILESDIR}/pt9.desktop" "${PN}.desktop"
	elif [[ -f "${FILESDIR}/${PN}-${PV}.desktop" ]]; then
		einfo "Using custom fallback desktop file from files/${PN}-${PV}.desktop"
		newmenu "${FILESDIR}/${PN}-${PV}.desktop" "${PN}.desktop"
	fi

	# 3. INSTALL MIME-TYPE ICONS (pka, pkt, pkz)
	local icon_path
	for icon in pka pkt pkz; do
		icon_path=$(find "${ED}/opt/pt" -type f -name "${icon}.png" 2>/dev/null | head -n 1)
		if [[ -n "${icon_path}" && -f "${icon_path}" ]]; then
			newicon -s 48x48 -c mimetypes "${icon_path}" "application-x-${icon}.png"
		fi
	done

	# 4. CREATE EXECUTABLE SYMLINK
	# Prioritize runner/EULA management scripts, then AppImage binaries
	if [[ -f "${ED}/opt/pt/packettracer" ]]; then
		dosym /opt/pt/packettracer /usr/bin/packettracer
	elif [[ -f "${ED}/opt/pt/pt-manage.sh" ]]; then
		dosym /opt/pt/pt-manage.sh /usr/bin/packettracer
	else
		local appimage_file
		appimage_file=$(find "${ED}/opt/pt" -maxdepth 2 -type f -name "*.AppImage" | head -n 1)
		if [[ -n "${appimage_file}" ]]; then
			local rel_path="${appimage_file#${ED}}"
			dosym "${rel_path}" /usr/bin/packettracer
		fi
	fi
}

pkg_postinst() {
	xdg_pkg_postinst

	einfo ""
	einfo "Cisco Packet Tracer 9.0.0 Installation Notes:"
	einfo "If this is your first launch and you need to accept the EULA or activate:"
	einfo "You can manually run the TUI activation scripts if required:"
	einfo "  /opt/pt/tui-eula.sh"
	einfo "  /opt/pt/tui-activation.sh"
	einfo ""
}