#!/bin/bash

isDeviceRight="n"
doPromtDevice="y"
installBootFiles="n"
installFilesystemFiles="n"

sdCreator.usage() {
  cat << EOF
Renux SD-CARD formater

This formats SD-CARD's for Beagleboard and Overo usage

Usage: $0 [-d device [-b bootFiles] [-f fileSystemFiles]

Options:
  -d,                   device
  -b,                   Boot files
  -f,                   Filessystem files
  -h,                   Shows this help information 

Example:
  ./sdCreator.bash 
  ./sdCreator.bash -d /dev/sdf
  
EOF
}

sdCreator.checkArgs() {
  # Check if sudo/root
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with sudo or as root" 
    exit 1
  fi

  # Parse commandline arguments
  while getopts "hd:b:f:" OPTION
  do
    case $OPTION in 
      d)
        device=$OPTARG
	doPromtDevice="n"
        ;;
      b)
        bootFiles=$OPTARG
        ;;
      f)
        fileSystemFiles=$OPTARG
        ;;
      h)
	sdCreator.usage
	exit 0
	;;
    esac
  done
  # Reset variable OPTIND (otherwise the scripts arguments stays the same in subsequent calls)
  OPTIND=1
}

sdCreator.promptDevice() {
  if [ "$doPromtDevice" == "y" ] ; then
    echo ""
    echo -n "Enter the path to you SD-CARD (ex. /dev/sdf): "
    read device
  fi
  sdCreator.checkDevice
}

sdCreator.checkDevice() {
 while [ "$isDeviceRight" != "y" ]; do
    clear 
    sudo fdisk -l $device
    echo ""
    echo "OBS: All data on device $device will be deleted!" 
    echo ""
    echo -n "Are you really sure that $device is your SD-CARD? (y/n) "
    read isDeviceRight
    echo ""

    if [ "$isDeviceRight" != "y" ]; then
      echo -n "Enter the path to you SD-CARD (ex. /dev/sdd): "
      read device
      echo ""
    fi
  done
}

sdCreator.createPartitionTable() {
  echo ""
  echo "Calculating cylinder size..."
  byteSize=$(sudo fdisk -l $device | awk 'NR==2 { print $5 }')
  cylinderSize=$(( $byteSize / 255 / 63 / 512 ))

  if [ $cylinderSize -lt 0 ] || [ $cylinderSize -eq 0 ] 
  then
    echo "Error: Calculated cylinder size can't be 0 or less ($cylinderSize))"
  fi

  echo ""
  echo "Creating partition table on image..."
  {
  echo ,9,0x0C,*
  echo ,,,-
  } | sudo sfdisk -D -H 255 -S 63 -C $cylinderSize $device
  sleep 1
}

sdCreator.formatImage() {
  sdCreator.umountImage
  sudo partprobe
  echo ""
  echo "Formating image..."
  sudo mkfs.vfat -F 32 -n "Boot" ${device}1
  echo ""
  sudo mkfs.ext3 -j -L "Renux" ${device}2
}

sdCreator.mountImage() {
  echo ""
  echo "Mounting image..."
  sdCreator.umountImage
  sudo mkdir -p /boot/Boot 
  sudo mkdir -p /boot/Renux
  sudo mount -t vfat ${device}1 /boot/Boot 
  sudo mount -t ext3 ${device}2 /boot/Renux
}

sdCreator.installBoot() {
  echo ""
  echo "Installing files to boot partition on image..."
  for parameter in $*
  do 
    sudo cp -r $parameter/* Boot
  done
}

sdCreator.installRootfs() {
  echo ""
  echo "Installing files to rootfs partition on image..."
  for parameter in $*
  do 
    sudo cp -r $parameter/* Renux
  done
}

sdCreator.umountImage() {
  echo ""
  echo "Unmounting image..."
  sudo umount ${device}1
  sudo umount ${device}2
  sync
  if [ -d "/media/Boot" ] ; then 
    sudo rm -rf /media/Boot
  fi
  if [ -d "/media/Renux" ] ; then 
    sudo rm -rf /media/Renux
  fi
}

sdCreator.checkArgs $@
sdCreator.promptDevice
sdCreator.createPartitionTable
sdCreator.formatImage
if [ "$installBootFiles" == "y" ] || [ "$installFilesystemFiles" == "y" ] ; then
  sdCreator.mountImage
  if [ "$installBootFiles" == "y" ] ; then
    sdCreator.installBoot $installBootFiles
  fi
  if [ "$installFilesystemFiles" == "y" ] ; then
    sdCreator.installRootfs $installFilesystemFiles
  fi
  sdCreator.umountImage
fi
