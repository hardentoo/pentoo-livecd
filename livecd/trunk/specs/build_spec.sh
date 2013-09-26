#!/bin/sh
#input arch ($1), profile ($2) and stage ($3), output working spec

set -e

VERSION_STAMP=2013.0
if [ ${3} = stage5 ]
then
	echo "version_stamp: 5-${VERSION_STAMP}"
else
	echo "version_stamp: ${VERSION_STAMP}"
fi
RC=RC2.0

echo "rel_type: ${2}"
echo "snapshot: 20130924 "
echo "portage_overlay: /usr/src/pentoo/portage/trunk"
echo "portage_confdir: /usr/src/pentoo/livecd/trunk/portage"

case ${3} in
	stage1)
		if [ ${1} = amd64 ]
		then
			if [ ${2} = hardened ]
			then
				echo "source_subpath: ${2}/stage3-amd64-${2}-20130801"
			elif [ ${2} = default ]
			then
				echo "source_subpath: ${2}/stage3-amd64-20130822"
			fi
		elif [ ${1} = i686 ]
		then
			if [ ${2} = hardened ]
			then
				echo "source_subpath: ${2}/stage3-i686-${2}-20130806"
			elif [ ${2} = default ]
			then
				echo "source_subpath: ${2}/stage3-i686-20130827"
			fi
		fi
		;;
	stage2)
		echo "source_subpath: ${2}/stage1-${1}-${VERSION_STAMP}"
		;;
	stage3)
		echo "source_subpath: ${2}/stage2-${1}-${VERSION_STAMP}"
		;;
	stage4)
		echo "source_subpath: ${2}/stage3-${1}-${VERSION_STAMP}"
		;;
	stage5)
		echo "source_subpath: ${2}/stage4-${1}-${VERSION_STAMP}"
		;;
	livecd-stage1)
		echo "source_subpath: ${2}/stage4-${1}-${VERSION_STAMP}"
		#echo "source_subpath: ${2}/stage5-${1}-5-${VERSION_STAMP}"
		;;
	livecd-stage2)
		echo "source_subpath: ${2}/livecd-stage1-${1}-${VERSION_STAMP}"
		echo "livecd/iso: /catalyst/release/Pentoo_${1}_${2}/pentoo-${1}-${2}-${VERSION_STAMP}_${RC}.iso"
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
		echo "kerncache_path: /catalyst/kerncache/${1}-${2}"

		echo "livecd/fsops: -comp xz -b 1048576 -no-recovery -noappend -Xdict-size 1048576"

		echo -e "\n# This is a set of arguments that will be passed to genkernel for all kernels"
		echo "# defined in this target.  It is useful for passing arguments to genkernel that"
		echo "# are not otherwise available via the livecd-stage2 spec file."
		if [ ${1} = amd64 ]
		then
			echo "livecd/gk_mainargs: --disklabel --dmraid --gpg --luks --lvm --zfs --compress-initramfs-type=xz"
		elif [ ${1} = i686 ]
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

if [ ${1} = amd64 ]
then
	echo "subarch: amd64"
elif [ ${1} = i686 ]
then
	echo "subarch: i686"
fi

if [ ${3} = stage5 ]
then
	echo "target: stage4"
else
	echo "target: ${3}"
fi

#fix profiles
case ${3} in
	stage1|stage2|stage3)
		if [ ${1} = amd64 ]
		then
			echo "profile: --force pentoo:pentoo/${2}/linux/${1}/bootstrap"
		elif [ ${1} = i686 ]
		then
			echo "profile: --force pentoo:pentoo/${2}/linux/x86/bootstrap"
		fi
		;;
	stage4|livecd-stage1|livecd-stage2)
		if [ ${1} = amd64 ]
		then
			echo "profile: pentoo:pentoo/${2}/linux/${1}"
		elif [ ${1} = i686 ]
		then
			echo "profile: pentoo:pentoo/${2}/linux/x86"
		fi
		;;
esac

[ -f ${3}-common.spec ] && cat ${3}-common.spec

case ${3} in
	stage1)
		if [ ${1} = amd64 ]
		then
			echo "pkgcache_path: /catalyst/tmp/packages/${1}-${2}-bootstrap/${3}"
		elif [ ${1} = i686 ]
		then
			echo "pkgcache_path: /catalyst/tmp/packages/x86-${2}-bootstrap/${3}"
		fi
		;;
	stage2|stage3)
		if [ ${1} = amd64 ]
		then
			echo "pkgcache_path: /catalyst/tmp/packages/${1}-${2}-bootstrap"
		elif [ ${1} = i686 ]
		then
			echo "pkgcache_path: /catalyst/tmp/packages/x86-${2}-bootstrap"
		fi
		;;
	stage4|livecd-stage1|livecd-stage2)
		if [ ${1} = amd64 ]
		then
			echo "pkgcache_path: /catalyst/tmp/packages/${1}-${2}"
		elif [ ${1} = i686 ]
		then
			echo "pkgcache_path: /catalyst/tmp/packages/x86-${2}"
		fi
		;;
esac
