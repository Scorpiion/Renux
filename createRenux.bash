#!/bin/bash

# Renux buildscript, a debian based Linux distro
# Copyright (C) 2011 Robert Åkerblom-Andersson
# 
# This program is free software under the GPL license, please 
# see the license.txt and gpl.txt files in the root directory

echo ""
echo "Renux version 1.3 buildscript"
echo ""

# Add scripts directory temporary to PATH (also for the root user)
PATH=$PWD/createRenuxHelpScripts:$PATH

# Source variables and functions from createRenux*.bash files
source $PWD/createRenuxHelpScripts/createRenuxVariables.bash
source $PWD/createRenuxHelpScripts/createRenuxFunctions.bash
source $PWD/createRenuxHelpScripts/createFS.bash
source $PWD/createRenuxHelpScripts/configureCompile.bash
source $PWD/createRenuxHelpScripts/createSdImage.bash

# Check commandline arguments
createRenux.checkArgs $@

# Show parameter values
createRenux.listParameters

# Run systemsetup
echo "Check so that the system has all packages needed installed"
systemSetup.update
systemSetup.installPackages
systemSetup.installBuildDeps
systemSetup.installStatus 
systemSetup.buildDepStatus

# Create build directories
echo "Creating directories..."
createRenux.createDirectories

# Get source code
echo ""
echo "Downloading source code"
echo ""

srcPackages=("x-loader" "u-boot" "Kernel" "Camera_Tools")
for buildPackage in "${srcPackages[@]}" ; do
  if [ ! -d "Renux_${buildPackage}" ] ; then
    echo "Downloading ${buildPackage} sources"
    git clone git://github.com/Scorpiion/Renux_${buildPackage}.git
    if [ "$buildPackage" = "Kernel" ] ; then
      cd Renux_Kernel 
      git submodule init 
      git submodule update 
      cd ..
    fi
  else
    echo "${buildPackage} sources already downloaded, checking for changes"
    git pull git://github.com/Scorpiion/Renux_${buildPackage}.git
    if [ "$buildPackage" = "Kernel" ] ; then
      cd Renux_Kernel 
      git submodule update 
      cd ..
    fi
  fi
  echo ""
done

# Create filesystem
createFS.createRootfsDir
createFS.debootstrapStage1
createFS.installQemuArmStatic
createFS.mountProcSys
createFS.debootstrapStage2
createFS.installRenuxFiles
createFS.runPostInstalltionCmds
createFS.aptUpdate
createFS.createUsers
createFS.umountProcSys
createFS.changeFilePremisions
 
# Configure and compile x-loader
configureCompile.checkArgs -n x-loader -d omap3530beagle_config -c -i $rootfs
configureCompile.setVars
configureCompile.enterTargetDir
configureCompile.clean
configureCompile.configure
configureCompile.compile
configureCompile.install
configureCompile.leaveTargetDir
 
# Configure and compile u-boot
configureCompile.checkArgs -n u-boot -d omap3_beagle_config -c -i $rootfs
configureCompile.setVars
configureCompile.enterTargetDir
configureCompile.clean
configureCompile.configure
configureCompile.compile
configureCompile.install
configureCompile.leaveTargetDir

# Configure and compile Linux kernel
cd Renux_Kernel
./buildKernel.bash
cp output/boot/uImage $rootfs/boot
cp -r output/lib $rootfs
cp output/linux-headers.tar.gz ..
cp output/renux_kernel.tar.gz ..
cd ..

# Configure and build camera tools
cd Renux_Camera_Tools
git submodule init
git submodule update
mkdir tmp
tar -zxf ../Renux_Kernel/output/linux-headers.tar.gz -C tmp 
unset CC
./buildTools.bash $PWD/tmp/ ../armel-squeeze-rootfs/
cd ..

# Create SD-CARD image and install Renux on image
echo $imageSize | createSdImage.getImageSize
createSdImage.createEmptyImage
createSdImage.createPartitionTable
createSdImage.createDeviceMaps
createSdImage.formatImage
createSdImage.mountImage
createSdImage.installBoot $rootfs/boot
createSdImage.installRootfs $rootfs
createSdImage.umountImage

# Create tar.gz packages of Renux
cd armel-squeeze-rootfs
tar -czf ../renux_ext_partition.tar.gz *
cd boot
tar -czf ../../renux_fat_partition.tar.gz *
cd ../..

# Leave build directory (entered in "createRenux.createDirectories")
createRenux.leaveBuild

echo ""
echo "Your Renux image is now ready!"

