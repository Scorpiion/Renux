#!/bin/bash

export SD_CARD_DEV=""
export BOOT_MOUNT="/media/Boot"
export ROOTFS_MOUNT="/media/Renux"
export buildDir=$PWD/"Renux_build"
export version="0.3"
export debianMirror="http://ftp.se.debian.org/debian"

export hostName="Renux"
export extraUsers="renux"
export includePkg="packages"
export excludePkg="packages"
export output="SD:4"
export imageSize="4"

export arch=armel
export dist=squeeze
export rootfs=$buildDir/$arch-$dist-rootfs
export runCmd="sudo chroot $rootfs /bin/su -c "
export installPkg="$runCmd /usr/bin/apt-get -y install "
export renux_fs="../renux_fs"
export extraPkg="\
locales, \
vim-tiny, \
openssh-server, \
sudo, \
"

# build-essential, \
# wireless-tools, \
# zd1211-firmware, \
# wpasupplicant, \
# usbutils, \
# xorg, \
# kdebase, \
# vlc, \
# iptables, \
# wget, \
# less, \
# alsa-utils, \
# i2c-tools, \
# vim-tiny, \
# vlc, \
# chromium-browser \


export CC="arm-linux-gnueabi-"
export JN=$(($(cat /proc/cpuinfo | grep processor | wc -l)*3)) 

