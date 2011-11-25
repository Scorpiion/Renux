#!/bin/bash

# Script variables (used by scripts started from this script)

source $PWD/createRenuxHelpScripts/systemSetup.bash 

createRenux.usage() {
  cat << EOF
Renux build script version $version

This script build a complete Renux system, either as a tar.gz packaged files that can be installed to a correctly 
formated SD-CARD or as SD-CARD image files, that can be copied to a SD-CARD without having to do any formating.

Usage: $0 [options]"

Options:
  -h,                   Host name (default "Renux")
  -u,                   Extra users (except root), can be a list seperated by "," with no spaces
  -i,                   List of extra packages to include (debian packages)
  -e,                   List of packages to exclude (debian packages)
  -o,                   Output: "tar.gz" for tar.gz packages for both partitions
                                "tar.bz" for tar.bz packages for both partitions
				"sd:X" for SD card image of X GB size
  -d,			List default values for options
  -h,                   Shows this help information 

Examples:
  Host name:
  ./createRenux.bash -n myEmbeddedSystem

  Extra user/users:
  ./createRenux.bash -u user1
  ./createRenux.bash -u user1,user2
  ./createRenux.bash -u user1,user2,user3

  Include extra packages to installation:
  ./createRenux.bash -i wireless-tools,vim-tiny,vlc

  Exclude packages to installation:
  ./createRenux.bash -e wireless-tools,vim-tiny,vlc

  Specify output mode:
  ./createRenux.bash -o tar.gz
  ./createRenux.bash -o tar.bz
  ./createRenux.bash -o sd:2
  ./createRenux.bash -o sd:8

  List default option values:
  ./createRenux.bash -d

  Show this help:
  ./createRenux.bash -h
  
EOF
}

createRenux.checkArgs() { 
  while getopts "n:u:i:e:o:dh" OPTION
  do
    case $OPTION in
      n)
	hostName=$OPTARG
	;;
      u)
	extraUsers=$OPTARG
	;;
      i)
	includePkg=$OPTARG
	;;
      e)
	excludePkg=$OPTARG
	;;
      o)
	output=$OPTARG
	;;
      d)
	createRenux.listDefault
	exit
	;;
      h)
	createRenux.usage
	exit
	;;
      *)
	createRenux.usage
	exit
	;;
    esac
  done

  if [ ! -z "$output" ] ; then
    if [ $(echo $output | awk -F ":" {'print $2'}) -gt 0 ] ; then 
      output=$(echo $output | awk -F ":" {'print $2'})
    fi
  fi
}

createRenux.listDefault() {
  echo "Default values:"
  echo -e "Hostname:\t\t $hostName"
  echo -e "Extra users:\t\t $extraUsers"
  echo -e "Includeed pacakges:\t $includePkg"
  echo -e "Excluded pacakges:\t $excludePkg"
  echo -e "Output:\t\t\t $output"
  echo ""
}

createRenux.createDirectories() {
  # Create build directory and mount directory for the filesystems
  if [ -d "$buildDir" ]; then
    rm -rf $buildDir
  fi
  mkdir $buildDir
  cd $buildDir
  sync
  sudo umount $BOOT_MOUNT
  sudo umount $ROOTFS_MOUNT
  sudo rm -rf $BOOT_MOUNT
  sudo rm -rf $ROOTFS_MOUNT
  sudo mkdir -p $BOOT_MOUNT
  sudo mkdir -p $ROOTFS_MOUNT
}

createRenux.leaveBuild() {
  cd ..
}

createRenux.mountFS() {
  echo ""
  echo "Mount filesystems..."
  sudo mount -t vfat ${SD_CARD_DEV}1 $BOOT_MOUNT
  sudo mount -t ext3 ${SD_CARD_DEV}2 $ROOTFS_MOUNT
}

createRenux.unmountFS() {
  echo ""
  echo "Unounting SD-CARD and flushing file system buffers"
  echo "(this part can take some time...)"
  sudo umount $BOOT_MOUNT
  sudo umount $ROOTFS_MOUNT
  sync
  sudo rmdir $BOOT_MOUNT
  sudo rmdir $ROOTFS_MOUNT
}

createRenux.installBootFiles() {
  echo "Install MLO and u-boot to bootpartition"
  echo ""
  sudo mv $ROOTFS_MOUNT/MLO $BOOT_MOUNT
  sudo mv $ROOTFS_MOUNT/u-boot.bin $BOOT_MOUNT
}

createRenux.createFS() {
  echo ""
  echo "Starting script to create filesystem..."
  createFS.bash
}

createRenux.installFS() {
  # Installing filesystem...
  sudo tar -jxvf armel-squeeze-rootfs.tar.bz -C $ROOTFS_MOUNT
}


