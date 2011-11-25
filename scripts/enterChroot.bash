#!/bin/bash

# Mount neccery proc and sys and chroot into the system
# Copyright (C) 2011 Robert Åkerblom-Andersson
# 
# This program is free software under the GPL license, please 
# see the license.txt and gpl.txt files in the root directory

arch=armel
dist=squeeze
rootfs=$PWD/$arch-$dist-rootfs
runCmd="chroot $rootfs "

# Check if root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run with sudo or as root" 
  exit 1
fi

# Mount proc and sys filesystem
mount -t proc proc $rootfs/proc
mount -t sysfs sysfs $rootfs/sys

chroot $rootfs /bin/bash

# Umount proc and sys filesystem
umount $rootfs/proc
umount $rootfs/sys

