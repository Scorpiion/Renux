#!/bin/bash

# Compile and install kernel and modules
# Copyright (C) 2011 Robert Åkerblom-Andersson
# 
# This program is free software under the GPL license, please 
# see the license.txt and gpl.txt files in the root directory

# Script variables
export BOOT_MOUNT="/media/Boot"
export ROOTFS_MOUNT="/media/Renux"
export CC="arm-linux-gnueabi-"
export JN=18

echo ""
echo "Copying uImage to $BOOT_MOUNT/uImage and $ROOTFS_MOUNT/boot/uImage..."
sudo cp arch/arm/boot/uImage $BOOT_MOUNT/uImage
sudo cp arch/arm/boot/uImage $ROOTFS_MOUNT/boot/uImage

echo ""
echo "Installing modules..."
sudo make ARCH=arm INSTALL_MOD_PATH=$ROOTFS_MOUNT modules_install

echo ""
echo "Installing firmware..."
sudo make ARCH=arm INSTALL_MOD_PATH=$ROOTFS_MOUNT firmware_install

echo ""
echo "Leaving kernel directory..."
cd ..

echo ""
echo "Unounting SD-CARD and flushing file system buffers"
echo "(this part can take some minutes...)"
sudo umount $BOOT_MOUNT
sudo umount $ROOTFS_MOUNT
sync

echo ""
echo "Now you can remove the SD-CARD and try it out!"
