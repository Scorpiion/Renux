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
export defconfig="omap3_renux_defconfig"
export JN=18
export isPartition="n"

echo "Clean kernel..."
sleep 1
make -j $JN ARCH=arm CROSS_COMPILE=${CC} mrproper CONFIG_DEBUG_SECTION_MISMATCH=y

echo "Configure kernel..."
sleep 1
make -j $JN ARCH=arm CROSS_COMPILE=${CC} omap3_renux_defconfig CONFIG_DEBUG_SECTION_MISMATCH=y

echo "Menuconfig..."
sleep 1
make -j $JN ARCH=arm CROSS_COMPILE=${CC} menuconfig CONFIG_DEBUG_SECTION_MISMATCH=y

echo "Compile kernel..."
sleep 1
make -j $JN ARCH=arm CROSS_COMPILE=${CC} uImage CONFIG_DEBUG_SECTION_MISMATCH=y

echo "Compile modules..."
sleep 1
make -j $JN ARCH=arm CROSS_COMPILE=${CC} modules CONFIG_DEBUG_SECTION_MISMATCH=y

echo "Compile firmware..."
sleep 1
make -j $JN ARCH=arm CROSS_COMPILE=${CC} firmware CONFIG_DEBUG_SECTION_MISMATCH=y


