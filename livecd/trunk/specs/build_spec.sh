#!/bin/sh
#input arch ($1) and stage ($2), output working spec

set -e

VERSION_STAMP=2013.0
echo "version_stamp: ${VERSION_STAMP}"
RC=RC1.7
case ${2} in
	stage1)
		if [ ${1} = amd64 ]
		then
			echo "source_subpath: hardened/stage3-amd64-hardened-20130523"
		elif [ ${1} = i686 ]
		then
			echo "source_subpath: hardened/stage3-i686-hardened-20130423"
		fi
		;;
	stage2)
		echo "source_subpath: hardened/stage1-${1}-${VERSION_STAMP}"
		;;
	stage3)
		echo "source_subpath: hardened/stage2-${1}-${VERSION_STAMP}"
		;;
	stage4)
		echo "source_subpath: hardened/stage3-${1}-${VERSION_STAMP}"
		;;
	livecd-stage1)
		echo "source_subpath: hardened/stage4-${1}-${VERSION_STAMP}"
		;;
	livecd-stage2)
		echo "source_subpath: hardened/livecd-stage1-${1}-${VERSION_STAMP}"
		echo "livecd/iso: /catalyst/release/Pentoo_${1}/pentoo-${1}-${VERSION_STAMP}_${RC}.iso"
		echo "livecd/volid: Pentoo Linux ${1} ${VERSION_STAMP} ${RC}"

		echo -e "\n# This option is the full path and filename to a kernel .config file that is"
		echo "# used by genkernel to compile the kernel this label applies to."
		if [ ${1} = amd64 ]
		then
			echo "boot/kernel/pentoo/config: /usr/src/pentoo/livecd/trunk/${1}/kernel/config-latest"
		elif [ ${1} = i686 ]
		then
			echo "boot/kernel/pentoo/config: /usr/src/pentoo/livecd/trunk/x86/kernel/config-latest"
		fi

		echo -e "\n# This allows the optional directory containing the output packages for kernel"
		echo "# builds.  Mainly used as a way for different spec files to access the same"
		echo "# cache directory.  Default behavior is for this location to be autogenerated"
		echo "# by catalyst based on the spec file."
		echo "kerncache_path: /catalyst/kerncache/${1}-hardened"

		if [ ${1} = amd64 ]
		then
			echo "livecd/fsops: -comp xz -b 1048576 -no-recovery -noappend -Xdict-size 1048576"
		elif [ ${1} = i686 ]
		then
			echo "livecd/fsops: -comp xz -b 1048576 -no-recovery -noappend -Xdict-size 1048576 -Xbcj x86"
		fi

		echo -e "\n# This is a set of arguments that will be passed to genkernel for all kernels"
		echo "# defined in this target.  It is useful for passing arguments to genkernel that"
		echo "# are not otherwise available via the livecd-stage2 spec file."
		if [ ${1} = amd64 ]
		then
			echo "livecd/gk_mainargs: --disklabel --dmraid --gpg --luks --lvm --zfs --compress-initramfs-type=xz"
		elif [ ${1} =i686 ]
		then
			echo "livecd/gk_mainargs: --disklabel --dmraid --gpg --luks --lvm --compress-initramfs-type=xz"
		fi

		echo "# This option is for merging kernel-dependent packages and external modules that"
		echo "# are configured against this kernel label."
		echo "boot/kernel/pentoo/packages:"
		echo "pentoo/pentoo"
		if [ ${1} = amd64 ]
		then
			echo "sys-fs/zfs"
		fi

esac

#grab common things
cat ${1}-common.spec full-common.spec
echo "target: ${2}"

#fix profiles
case ${2} in
	stage1|stage2|stage3)
		if [ ${1} = amd64 ]
		then
			echo "profile: --force pentoo:pentoo/hardened/linux/${1}/bootstrap"
		elif [ ${1} = i686 ]
		then
			echo "profile: --force pentoo:pentoo/hardened/linux/x86/bootstrap"
		fi
		;;
	stage4|livecd-stage1|livecd-stage2)
		if [ ${1} = amd64 ]
		then
			echo "profile: pentoo:pentoo/hardened/linux/${1}"
		elif [ ${1} = i686 ]
		then
			echo "profile: pentoo:pentoo/hardened/linux/x86"
		fi
		;;
esac

[ -f ${2}-common.spec ] && cat ${2}-common.spec

case ${2} in
	stage1)
		if [ ${1} = amd64 ]
		then
			echo "pkgcache_path: /catalyst/tmp/packages/${1}-hardened-bootstrap/${2}"
		elif [ ${1} = i686 ]
		then
			echo "pkgcache_path: /catalyst/tmp/packages/x86-hardened-bootstrap/${2}"
		fi
		;;
	stage2|stage3)
		if [ ${1} = amd64 ]
		then
			echo "pkgcache_path: /catalyst/tmp/packages/${1}-hardened-bootstrap"
		elif [ ${1} = i686 ]
		then
			echo "pkgcache_path: /catalyst/tmp/packages/x86-hardened-bootstrap"
		fi
		;;
	stage4|livecd-stage1|livecd-stage2)
		if [ ${1} = amd64 ]
		then
			echo "pkgcache_path: /catalyst/tmp/packages/${1}-hardened"
		elif [ ${1} = i686 ]
		then
			echo "pkgcache_path: /catalyst/tmp/packages/x86-hardened"
		fi
		;;
esac
