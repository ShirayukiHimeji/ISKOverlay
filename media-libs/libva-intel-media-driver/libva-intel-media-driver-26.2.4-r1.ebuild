# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake-multilib flag-o-matic

MY_PV="${PV%_pre}"
SRC_URI="https://github.com/intel/media-driver/archive/intel-media-${MY_PV}.tar.gz"
S="${WORKDIR}/media-driver-intel-media-${MY_PV}"
if [[ ${PV} != *_pre* ]] ; then
	KEYWORDS="amd64"
fi

DESCRIPTION="Intel Media Driver for VA-API (iHD) [Gen12/Alder Lake optimized]"
HOMEPAGE="https://github.com/intel/media-driver"

LICENSE="MIT BSD redistributable? ( no-source-code )"
SLOT="0"
IUSE="+redistributable test X"

RESTRICT="!test? ( test )"

DEPEND=">=media-libs/gmmlib-22.10.0:=[${MULTILIB_USEDEP}]
	>=media-libs/libva-2.22.0[X?,${MULTILIB_USEDEP}]
"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}"/${PN}-23.3.4-Remove-unwanted-CFLAGS.patch
	"${FILESDIR}"/${PN}-23.3.4_testing_in_src_test.patch
)

multilib_src_configure() {
	# https://github.com/intel/media-driver/issues/356
	append-cxxflags -D_FILE_OFFSET_BITS=64

	local mycmakeargs=(
		-DMEDIA_BUILD_FATAL_WARNINGS=OFF
		-DMEDIA_RUN_TEST_SUITE=$(usex test)
		-DBUILD_TYPE=Release
		-DPLATFORM=linux
		-DCMAKE_DISABLE_FIND_PACKAGE_X11=$(usex !X)
		-DENABLE_NONFREE_KERNELS=$(usex redistributable)
		-DLATEST_CPP_NEEDED=ON # Seems to be the best option for now
		-D{GEN{8,9,11},MTL,ARL,LNL,BMG,PTL,CRI,NVL,XE3P_HPM_SUPPORT,XE3P_LPG}=OFF
	)
	local CMAKE_BUILD_TYPE="Release"
	cmake_src_configure
}
