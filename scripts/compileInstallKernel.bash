#!/bin/bash

# Compile and install kernel and modules
# Copyright (C) 2011 Robert Åkerblom-Andersson
# 
# This program is free software under the GPL license, please 
# see the license.txt and gpl.txt files in the root directory.

# Script variables
export KERNEL_DIR="Beagleboard-xM-Linux-Kernel"
export CC="arm-linux-gnueabi-"
export defconfig="omap3_beagle_defconfig"
export JN=18

echo "Starting script to configure, compile and install Linux kernel"

echo ""
echo "Download Linux kernel sources..."
git clone git://github.com/Scorpiion/$KERNEL_DIR.git

echo ""
echo "Entering kernel directory..."
cd $KERNEL_DIR

echo ""
echo "Delete all old .config files from kernel..."
make ARCH=arm CROSS_COMPILE=${CC} mrproper

echo ""
echo "Configure kernel with defconfig $defconfig..."
make ARCH=arm CROSS_COMPILE=${CC} $defconfig

echo ""
echo "Compile kernel..."
make -j $JN ARCH=arm CROSS_COMPILE=${CC} uImage

echo ""
echo "Compile modules..."
make -j $JN ARCH=arm CROSS_COMPILE=${CC} modules 

echo ""
echo "Compile firmware..."
make -j $JN ARCH=arm CROSS_COMPILE=${CC} firmware

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
echo "The kernel and modules are now compiled and installed!"

