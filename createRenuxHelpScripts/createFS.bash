#!/bin/bash

# Create a filesystem for Renux with the help of debootstrap
# Copyright (C) 2011 Robert Åkerblom-Andersson
# 
# This program is free software under the GPL license, please 
# see the license.txt and gpl.txt files in the root directory

createFS.createRootfsDir() {
  # Create a directory for the filesystem
  mkdir -p $rootfs
}

createFS.debootstrapStage1() {
  # Create filesystem
  echo "Starting to build filesystem with debootstrap..."
  sudo debootstrap --verbose --foreign --include "$extraPkg" --arch $arch --components "main,contrib,non-free" $dist $rootfs $debianMirror
}

createFS.installQemuArmStatic() {
  # Copy qemu-arm-static so that it is possible to chroot into the system,
  # to make emulation possible
  sudo cp $(which qemu-arm-static) $rootfs/usr/bin/
}

createFS.mountProcSys() {
  # Mount proc and sys filesystem
  sudo mount -t proc proc $rootfs/proc
  sudo mount -t sysfs sysfs $rootfs/sys
}

createFS.umountProcSys() {
  # Mount proc and sys filesystem
  sudo umount $rootfs/proc
  sudo umount $rootfs/sys
}

createFS.debootstrapStage2() {
  # Continue with second stage in debootstrap
  echo ""
  echo "Starting stage two of debootstrap..."
  sudo chroot $rootfs /debootstrap/debootstrap --second-stage
}

createFS.installRenuxFiles() {
  # Add Renux specific files
  pushd .
  cd $renux_fs 
  tar -czf renux_fs.tar.gz *
  sudo tar -zxvf renux_fs.tar.gz -C $rootfs
  rm renux_fs.tar.gz
  popd
}

createFS.runPostInstalltionCmds() {
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

  # Allow non root users to use Xorg
  sudo echo "allowed_users=anybody" >> $rootfs/etc/X11/Xwrapper.config
}

createFS.aptUpdate() {
  # Setup package managment and install some packages
  $runCmd 'apt-get -y update'
}

createFS.createUsers() {
  # Set root password and create user $username and it's set password
  $runCmd 'echo -e "root\nroot" | passwd root'
  listofUsers=$(echo $extraUsers | awk 'BEGIN { FS="," } { for(i=1; i<=NF; i++) print $i }')
  for username in $listofUsers ; do
    $runCmd 'useradd -m -s /bin/bash '$username
    $runCmd 'echo -e "'$username'\n'$username'" | passwd '$username
  done
}

# Setup language settings
#$installPkg console-data
#runCmd ...
