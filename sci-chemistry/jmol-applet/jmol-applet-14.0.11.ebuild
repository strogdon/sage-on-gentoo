# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit eutils java-pkg-2 java-ant-2

MY_P="Jmol"
MY_PN="jmol"
DESCRIPTION="Jmol is a java molecular viever for 3-D chemical structures."

SRC_URI="
	mirror://sourceforge/${MY_PN}/${MY_P}-${PV}-full.tar.gz 
	jsmol? ( mirror://sagemath/jspecview-1169.tar.bz2 
		mirror://sagemath/jsmol-584.tar.bz2 
		mirror://sagemath/srcjs-19432.tar.bz2 )"

HOMEPAGE="http://jmol.sourceforge.net/"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
LICENSE="LGPL-2.1"
S="${WORKDIR}/${MY_PN}-${PV}"

RESTRICT="mirror"

#IUSE="sage"
IUSE="jsmol"

SLOT="0"

COMMON_DEP="dev-java/commons-cli:1
	sci-chemistry/jspecview
	sci-libs/jmol-acme:0
	>=sci-libs/naga-3.0"

RDEPEND=">=virtual/jre-1.6
	${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.6
	${COMMON_DEP}
	dev-java/ant-contrib
	dev-java/jaxp
	dev-java/saxon:6.5
	jsmol? ( >=dev-lang/closure-compiler-bin-20120305 )"

pkg_setup() {
	java-pkg-2_pkg_setup
}

src_prepare() {
	edos2unix build.xml
#	epatch "${FILESDIR}"/${MY_PN}-${PV}-nointl.patch
#	epatch "${FILESDIR}"/textformat.patch

	# Jmol.js-12.3.27 patch 
#	edos2unix Jmol.js
#	epatch "${FILESDIR}"/${PN}-Jmol.js-12.3.27-unix.patch

	# hack to add JmolHelp.html for trac 12299
#	if use sage; then
#		epatch "${FILESDIR}"/jmol-add-help.patch || die
#	fi

	rm -vf "${S}"/jsmol.zip "${S}/appletweb/jsmol.zip" || die "Failed to remove jsmol.zip files."

	rm -vf "${S}"/*.jar "${S}"/plugin-jars/*.jar || die "Failed to remove jars."
	pushd "${S}/jars"

# We still have to use netscape.jar on amd64 until a nice way to include plugin.jar comes along.
	if use amd64; then
		mv -v netscape.jar netscape.tempjar || die "Failed to move netscape.jar."
		rm -vf *.jar *.tar.gz || die "Failed to remove jars."
		rm -vf t.zip || die "Failed to remove t.zip."
		mv -v netscape.tempjar netscape.jar || die "Failed to move netscape.tempjar."
	fi

	java-pkg_jar-from jmol-acme jmol-acme.jar Acme.jar
	java-pkg_jar-from commons-cli-1 commons-cli.jar commons-cli-1.0.jar
	java-pkg_jar-from jaxp jaxp.jar gnujaxp.jar
	java-pkg_jar-from naga naga.jar naga-3_0.jar
	java-pkg_jar-from saxon-6.5 saxon.jar
	java-pkg_jar-from junit junit.jar
	java-pkg_jar-from jspecview jspecview.jar JSpecView.jar
	popd

	pushd "${S}/tools"
	rm -vf *.jar || die "Failed to remove jars."
	java-pkg_jar-from ant-contrib ant-contrib.jar
#	java-pkg_jar-from jsch jsch.jar
	popd

#	mkdir -p "${S}/build/appjars" || die

	if use jsmol; then
		pushd "$WORKDIR}"/jspecview-1169
		rm -vf JSpecView/libs/*.jar JSpecView/build/*.jar || die "Failed to remove jars."
		popd

		pushd "${WORKDIR}"/jsmol-584
		edos2unix build_01_fromjmol_stable.xml build_02_fromjspecview.xml build_03_tojs_stable.xml
		epatch "${FILESDIR}/build_01_fromjmol_stable.xml.patch"
		epatch "${FILESDIR}/build_02_fromjspecview.xml.patch"
		epatch "${FILESDIR}/build_03_tojs_stable.xml.patch"

		rm -vf dist/jsmol.zip || die "Failed to remove jmol.zip."
#		mv -v jars/closure_compiler.jar jars/closure_compiler.tempjar
		rm -vf jars/*.jar || die "Failed to remove jars."
#		mv -v jars/closure_compiler.tempjar jars/closure_compiler.jar
#		java-pkg_jar-from closure-compiler-bin-0 closure-compiler-bin.jar closure_compiler.jar
		ln -s "${EPREFIX}/opt/closure-compiler-bin-0/lib/closure-compiler-bin.jar" jars/closure_compiler.jar
		popd
		ln -s "${WORKDIR}"/srcjs srcjs
	fi
}

src_compile() {
	# prevent absorbing dep's classes
#	eant -Dlibjars.uptodate=true main
	eant main

	if use jsmol; then
		cd "${WORKDIR}"/jsmol-584
		eant -buildfile build_01_fromjmol_stable.xml
		eant -buildfile build_02_fromjspecview.xml
		eant -buildfile build_03_tojs_stable.xml
	fi
}

src_install() {
	insinto "${JAVA_PKG_SHAREPATH}"
#	if use sage; then
#		doins JmolHelp.html
#	fi
	doins build/Jmol.jar build/JmolData.jar build/JmolLib.jar build/Jvxl.jar build/JmolApplet*.jar applet.classes
#	doins appletweb/*.jar
	doins -r build/applet-classes/*
#	doins -r build/appletjars/*
	doins -r build/classes/*
	doins "${FILESDIR}"/caffeine.xyz "${FILESDIR}"/index.html
}
