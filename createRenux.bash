#!/bin/bash

# Renux buildscript, a debian based Linux distro
# Copyright (C) 2011 Robert Åkerblom-Andersson
# 
# This program is free software under the GPL license, please 
# see the license.txt and gpl.txt files in the root directory

echo ""
echo "Renux version 1.0 buildscript"
echo ""
sleep 1

# Add scripts directory temporary to PATH (also for the root user)
PATH=$PWD/createRenuxHelpScripts:$PATH

# Source variables and functions from createRenux*.bash files
source $PWD/createRenuxHelpScripts/createRenuxVariables.bash
source $PWD/createRenuxHelpScripts/createRenuxFunctions.bash
source $PWD/createRenuxHelpScripts/configureCompile.bash
source $PWD/createRenuxHelpScripts/createSdImage.bash

# Check commandline arguments
createRenux.checkArgs $@

# Run systemsetup
echo "Check so that the system has all packages needed installed"
systemSetup.update
systemSetup.installPackages
systemSetup.installBuildDeps
systemSetup.installStatus 
systemSetup.buildDepStatus

# Create build directories
createRenux.createDirectories

# Get source code
echo "Downloading source code"

srcPackages=("x-loader" "u-boot" "linux")
for buildPackage in "${srcPackages[@]}" ; do
  if [ ! -d "$src/${crossSrcPrefix}_${buildPackage}" ] ; then
    echo "Downloading ${buildPackage} sources"
    git clone git://github.com/Scorpiion/Renux_${buildPackage}.git
  else
    echo "${buildPackage} sources already downloaded, checking for changes"
    git fetch git://github.com/Scorpiion/Renux_cross_${buildPackage}.git
  fi
  echo ""
done

exit

# Create filesystem
createRenux.createFS

# Configure and compile x-loader
configureCompile.checkArgs -n x-loader -d omap3530beagle_config -c -i $rootfs
configureCompile.setVars
configureCompile.enterTargetDir
configureCompile.clean
configureCompile.configure
configureCompile.compile
configureCompile.leaveTargetDir
configureCompile.install

# Configure and compile u-boot
configureCompile.checkArgs -n u-boot -d omap3_beagle_config -c -i $rootfs
configureCompile.setVars
configureCompile.enterTargetDir
configureCompile.clean
configureCompile.configure
configureCompile.compile
configureCompile.leaveTargetDir
configureCompile.install

# Configure and compile Linux kernel
configureCompile.checkArgs -n linux -d omap3_renux_defconfig -c -i $rootfs
configureCompile.setVars
configureCompile.enterTargetDir
configureCompile.clean
configureCompile.configure
configureCompile.compile
configureCompile.leaveTargetDir
configureCompile.install

# Create SD-CARD image and install Renux
echo $output | createSdImage.getImageSize
createSdImage.createEmptyImage
createSdImage.createPartitionTable
createSdImage.createDeviceMaps
createSdImage.formatImage
createSdImage.mountImage
createSdImage.installBoot() $rootfs/boot
createSdImage.installRootfs() $rootfs
createSdImage.umountImage

# Leave build directory (entered in "createRenux.createDirectories")
createRenux.leaveBuild

echo ""
echo "Your Renux image is now ready!"


