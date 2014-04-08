# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI=4

inherit java-pkg-2 java-ant-2 subversion

#SRC_URI="mirror://gentoo/${P}.tar.bz2"
MY_PV=${PV//./_}
#MY_PVR="${MY_PV}-r82"
MY_PVR="${MY_PV}"

DESCRIPTION="Simplified Java NIO asynchronous sockets"
HOMEPAGE="http://code.google.com/p/naga/"

ESVN_REPO_URI="http://naga.googlecode.com/svn/trunk/"
ESVN_REVISION="82"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=virtual/jdk-1.5
	dev-java/ant-core"
RDEPEND=">=virtual/jre-1.5"

src_compile() {
	eant build
}

src_install() {
	java-pkg_newjar _DIST/${PN}-${MY_PVR}.jar ${PN}.jar
}
