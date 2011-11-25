#!/bin/bash

export SD_CARD_DEV=""
export BOOT_MOUNT="/mnt/boot"
export ROOTFS_MOUNT="/mnt/rootfs"
export buidDir=$PWD/"Renux_build"
export version="0.2"

export hostName="Renux"
export extraUsers="renux"
export includePkg="pacakges"
export excludePkg="pacakges"
export output="SD:4"

export isDeviceRight="n"

export username="robert"
export arch=armel
export dist=squeeze
export rootfs=$PWD/$arch-$dist-rootfs
export runCmd="sudo chroot $rootfs /bin/su -c "
export installPkg="$runCmd /usr/bin/apt-get -y install "
export files="../renux_fs"
export extraPkg="\
build-essential, \
locales, \
wireless-tools, \
zd1211-firmware, \
wpasupplicant, \
usbutils, \
xorg, \
kdebase, \
vlc, \
openssh-server, \
iptables, \
wget, \
less, \
alsa-utils, \
i2c-tools, \
vim-tiny, \
vlc, \
chromium-browser \
"

export CC="arm-linux-gnueabi-"
export JN=$(($(cat /proc/cpuinfo | grep processor | wc -l)*3)) 

