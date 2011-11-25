#!/bin/bash

# Create a filesystem for Renux with the help of debootstrap
# Copyright (C) 2011 Robert Åkerblom-Andersson
# 
# This program is free software under the GPL license, please 
# see the license.txt and gpl.txt files in the root directory

# Create a directory for the filesystem
mkdir -p $rootfs

# Create filesystem
echo ""
echo "Starting to build filesystem with debootstrap..."
sudo debootstrap --verbose --foreign --include "$extraPkg" --arch $arch $dist $rootfs http://ftp.us.debian.org/debian

# Copy qemu-arm-static so that it is possible to chroot into the system,
# to make emulation possible
sudo cp $(which qemu-arm-static) $rootfs/usr/bin/

# Mount proc and sys filesystem
sudo mount -t proc proc $rootfs/proc
sudo mount -t sysfs sysfs $rootfs/sys

# Continue with second stage in debootstrap
echo ""
echo "Starting stage two of debootstrap..."
sudo chroot $rootfs /debootstrap/debootstrap --second-stage

# Add Renux specific files
sudo cp $files/fstab               $rootfs/etc/
sudo cp $files/hostname            $rootfs/etc/
sudo cp $files/hosts               $rootfs/etc/
sudo cp $files/inittab             $rootfs/etc/
sudo cp $files/interfaces          $rootfs/etc/network/
sudo cp $files/issue               $rootfs/etc/
sudo cp $files/issue.net           $rootfs/etc/
sudo cp $files/issue.dpkg-dist     $rootfs/etc/
sudo cp $files/resolv.conf         $rootfs/etc/
sudo cp $files/setupWireless.bash  $rootfs/usr/bin/
sudo cp $files/sources.list        $rootfs/etc/apt/ 

# Trigger post install scripts
$runCmd 'DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true LC_ALL=C LANGUAGE=C LANG=C dpkg --configure -a'

# Create serial device nodes
$runCmd 'mknod -m 660 /dev/ttyS0 c 4 64'
$runCmd 'mknod -m 660 /dev/ttyS1 c 4 65'
$runCmd 'mknod -m 660 /dev/ttyS2 c 4 66'
$runCmd 'mknod -m 660 /dev/ttyS02 c 4 67'
$runCmd 'mknod -m 660 /dev/ttySO2 c 4 68'
$runCmd 'mknod -m 660 /dev/ttyS3 c 4 69'

# Create softlinks for vim
$runCmd 'ln -s /usr/bin/vim-tiny /usr/bin/vim'

# Setup package managment and install some packages
$runCmd 'apt-get -y update'

# Set root password and create user $username and it's set password
$runCmd 'echo -e "root\nroot" | passwd root'
listofUsers=$(echo $extraUsers | awk 'BEGIN { FS="," } { for(i=1; i<=NF; i++) print $i }')
for username in $listofUsers ; do
  $runCmd 'useradd -m -s /bin/bash '$username
  $runCmd 'echo -e "'$username'\n'$username'" | passwd '$username
done

# Allow anyone to use Xorg
# echo "allowed_users=anybody" >> /etc/X11/Xwrapper.config

# Setup language settings
#$installPkg console-data
#runCmd ...

echo "Creating tar.bz package of the new roofs..."
echo "(it might take a minute of two)"
echo ""
sudo umount $rootfs/proc
sudo umount $rootfs/sys
cd $rootfs
sudo tar -cjf $rootfs.tar.bz *
cd ..

echo "Done creating filesystem!"
