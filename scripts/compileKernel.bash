#!/bin/bash

# Compile and install kernel and modules
# Copyright (C) 2011 Robert Åkerblom-Andersson
# 
# This program is free software under the GPL license, please 
# see the license.txt and gpl.txt files in the root directory

# Script variables
export BOOT_MOUNT="/media/usb1"
export ROOTFS_MOUNT="/media/usb2"
export CC="arm-linux-gnueabi-"
export defconfig="omap3_renux_defconfig"
export JN=18
export isPartition="n"

echo "Configure kernel..."
make -j $JN ARCH=arm CROSS_COMPILE=${CC} omap3_renux_defconfig CONFIG_DEBUG_SECTION_MISMATCH=y

echo "Compile kernel..."
make -j $JN ARCH=arm CROSS_COMPILE=${CC} uImage CONFIG_DEBUG_SECTION_MISMATCH=y

echo "Compile modules..."
make -j $JN ARCH=arm CROSS_COMPILE=${CC} modules CONFIG_DEBUG_SECTION_MISMATCH=y

echo "Compile firmware..."
make -j $JN ARCH=arm CROSS_COMPILE=${CC} firmware CONFIG_DEBUG_SECTION_MISMATCH=y


