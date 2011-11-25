#!/bin/bash

# Configure and compile scripts for various projects
# Copyright (C) 2011 Robert Åkerblom-Andersson
# 
# This program is free software under the GPL license, please 
# see the license.txt and gpl.txt files in the root directory



configureCompile.usage() {
  cat << EOF
Configure, Compile script

This script cleans, configures and compile source code for these project:
  Renux_x-loader (target x-loader)
  Renux_u-boot (target u-boot)
  Renux_Linux_kernel (target linux)

Usage: $0 -n [nameOfProject] [options]"

Options:
  -n,                   Target name
  -d,                   Defconfig
  -l,                   List defconfigs for target name (must be used togother with -n)
  -c,                   Configure and compile
  -i,                   Install
  -h,                   Shows this help information 

Examples:
  Show defconfigs
  ./configureCompile.bash -n x-loader -l
  ./configureCompile.bash -n u-boot -l
  ./configureCompile.bash -n linux -l

  Configure and compile
  ./configureCompile.bash -n x-loader -d omap3530beagle_config -c
  ./configureCompile.bash -n u-boot -d omap3_beagle_config -c
  ./configureCompile.bash -n linux -d omap3_renux_defconfig -c

  Install
  ./configureCompile.bash -n x-loader -i
  ./configureCompile.bash -n u-boot -i
  ./configureCompile.bash -n linux -i
  
EOF
}

configureCompile.listTargetsAndDefconfig() { 
  currDir=$(pwd)

  i=0
  case $targetName in
    x-loader)
      targets=$(cd Renux_x-loader/board/ && ls -l | awk 'NR > 1 { print $8 }')
      ;;
    u-boot)
      targets=$(cd Renux_u-boot/ && awk '(NF && $1 !~ /^#/) { print $1"_config" }' boards.cfg)
      ;;
    linux)
      targets=$(cd Renux_linux/arch/arm/configs/ && ls -l | awk 'NR > 1 { print $8 }')
      ;;
    *)
      echo "Target \"$targetName\" does not exist, try one of:"
      echo "  ./configureCompile.bash -l x-loader"
      echo "  ./configureCompile.bash -l u-boot"
      echo "  ./configureCompile.bash -l linux"
      exit 1
      ;;
  esac

  echo "Defconfigs for $targetName:"
  for target in $(echo $targets | tr ";" "\n")
  do
    if [ "$targetName" == "x-loader" ]
    then
      echo -ne "  ${target}_config"
      if [ ${#target} -lt 8 ]
      then
	echo -en "     \t"
      else
	echo -en "\t"
      fi
    else
      if [ ${#target} -lt 14 ]
      then
	echo -ne "  ${target}     \t"
      elif [ ${#target} -gt 20 ]
      then
	echo -ne "  ${target}"
      else
	echo -ne "  ${target}\t"
      fi
    fi
  
    i=$(($i+1))

    if [ $(($i%6)) -eq 0 ] 
    then
      echo ""
    fi 
  done
  echo ""
  cd $currDir
}

configureCompile.setVars() {
  cleanTarget="mrproper"

  case $targetName in
    x-loader)
      compileTarget=""
      ;;
    u-boot)
      compileTarget=""
      ;;
    linux)
      compileTarget="uImage"
      ;;
    *)
      compileTarget=""
      ;;
  esac

  if [ -z "$defconfig" ] 
  then
    defconfig=""
  fi
 
  currDir=$PWD
  srcDir="Renux_$targetName"
}

configureCompile.checkArgs() {
  while getopts "n:d:ci:lh" OPTION
  do
    case $OPTION in
      n)
	targetName=$OPTARG
	;;
      d)
	defconfig=$OPTARG
	;;
      c)
	configureCompile="y"
	;;
      i)
	doInstall="y"
	projectInstall=$OPTARG
	;;
      l)
	configureCompile.listTargetsAndDefconfig
	exit 0
	;;
      h)
	configureCompile.usage
	exit 0
	;;
    esac
  done
  # Reset variable OPTIND (otherwise the scripts arguments stays the same in subsequent calls)
  OPTIND=1

  if [[ -z "$configureCompile" ]] && [[ -z "$doInstall" ]]
  then
    configureCompile.usage 
    exit 1
  else  
    if [ -z "$targetName" ] 
    then
      configureCompile.usage
      exit 1
    fi

    if [[ ! -z "$doInstall" ]] ; then
      if [[ -z "$projectInstall" ]] ; then
	configureCompile.usage
	exit 1
      fi
    fi
  fi
}

configureCompile.enterTargetDir() {
  echo ""
  echo "Entering $targetName directory..."
  cd $srcDir
  sleep 1
}

configureCompile.clean() {
  echo ""
  echo "Cleaning up $targetName..."
  sleep 1
  make -j $JN ARCH=arm CROSS_COMPILE=${CC} $cleanTarget
}

configureCompile.configure() {
  echo ""
  echo "Configure $targetName..."
  sleep 1
  make -j $JN ARCH=arm CROSS_COMPILE=${CC} $defconfig
}

configureCompile.compile() {
  echo ""
  echo "Compile $targetName..."
  sleep 1
  make -j $JN ARCH=arm CROSS_COMPILE=${CC} $compileTarget
}

configureCompile.install() {
  echo ""
  echo "Installing $targetName..."
  sleep 1

  mkdir -p $projectInstall/boot/
  case $targetName in
    x-loader)
      echo ""
      echo "Installing x-loader..."
      sudo cp MLO $projectInstall/boot/
      ;;
    u-boot)
      echo ""
      echo "Installing u-boot..."
      sudo cp u-boot.bin $projectInstall/boot/
      ;;
    linux)
      echo ""
      echo "Installing uImage..."
      sudo cp arch/arm/boot/uImage $projectInstall/boot/

      echo ""
      echo "Installing modules..."
      sudo make ARCH=arm INSTALL_MOD_PATH=$projectInstall modules_install

      echo ""
      echo "Installing firmware..."
      sudo make ARCH=arm INSTALL_MOD_PATH=$projectInstall firmware_install
      ;;
    *)
      echo ""
      echo "Error, target \"$targetName\" does not exist. Try one of x-loader, u-boot, linux"
      ;;
  esac
}

configureCompile.leaveTargetDir() {
  echo ""
  echo "Done, leaving \"$srcDir\"..."
  cd $buildDir
}

# Function calls to run script independently
# source $PWD/createRenuxHelpScripts/createRenuxVariables.bash
# configureCompile.checkArgs $@
# configureCompile.setVars
# configureCompile.enterTargetDir
# if [[ ! -z "$configureCompile" ]] ; then 
#   configureCompile.clean
#   configureCompile.configure
#   configureCompile.compile
# fi
# if [[ ! -z "$doInstall" ]] ; then
#   configureCompile.install
# fi
# configureCompile.leaveTargetDir
