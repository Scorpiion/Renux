#!/bin/bash

# imageManager.bash, script to install images from file into SD-CARD 
# and to create image files from SD-CARDs
#
# Copyright (C) 2011 Robert Åkerblom-Andersson
# 
# This program is free software under the GPL license, please 
# see the license.txt and gpl.txt files in the root directory

isDeviceRight="n"
bs=1024
update=1

#dd if=/dev/zero of=./testImage bs=$bs >progress.txt 2>&1 & pid=$!

imageManager.usage() {
  cat << EOF
Renux Image Manager

This script install or backups SD-CARD images

Usage: $0 -w imageName [-d deviceName]
       $0 -s imageName [-d deviceName]

Options:
  -w,                   Write image
  -s,                   Save image
  -d,			Device name (prompted for if left out)
  -h,                   Shows this help information 

Examples:
  Install Renux image to SD-CARD
  ./imageManager.bash -w renux_4_gb.img
  ./imageManager.bash -w renux_4_gb.img -d /dev/sdf

  Backup image from from SD-CARD
  ./imageManager.bash -s renux_projectX_backup.img
  ./imageManager.bash -s renux_projectX_backup.img -d /dev/sdf
  
EOF
}

imageManager.checkArgs() {
  # Check if sudo/root
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with sudo or as root" 
    exit 1
  fi

  # Parse commandline arguments
  while getopts "w:s:d:h" OPTION
  do
    case $OPTION in
      w)
	action="write"
	imgName=$OPTARG
	;;
      s)
	action="save"
	imgName=$OPTARG
	;;
      d)
	device=$OPTARG
	;;
      h)
	imageManager.usage
	exit 0
	;;
    esac
  done
  # Reset variable OPTIND (otherwise the scripts arguments stays the same in subsequent calls)
  OPTIND=1

  if [ -z "$imgName" ]
  then
    imageManager.usage 
    exit 1
  else  
    if [ -z "$device" ] 
    then
      imageManager.promptDevice
    else
      imageManager.checkDevice
    fi
  fi
}

imageManager.promptDevice() {
  echo ""
  echo -n "Enter the path to you SD-CARD (ex. /dev/sdd): "
  read device
  imageManager.checkDevice
}

imageManager.checkDevice() {
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

imageManager.procesImage() {
  if [ "$action" == "write" ] ; then
    imageManager.writeImage
  elif [ "$action" == "save" ] ; then
    echo "Saving image from SD-CARD..."
  else
    imageManager.saveImage
    exit 1
  fi
}

imageManager.writeImage() {
  dd if=$imgName of=$device bs=${bs} >progress.txt 2>&1 & pid=$!
}

imageManager.saveImage() {
  dd if=$device of=$imgName bs=${bs} >progress.txt 2>&1 & pid=$!
}

imageManager.checkProcess() {
  echo "" > progress.txt
  kill -USR1 $pid
  sizeDone=$(awk 'NR==4 {print $3 $4}' progress.txt)
  sizeDone=$(echo ${sizeDone:1:$((${#sizeDone}-2))})
  timeDone=$(awk 'NR==4 {print $6}' progress.txt)
  timeDone=$(echo $timeDone | awk -F"." '{print $1}')
  timeDone=$(date +%H:%M:%S -d "1970-01-01 $timeDone sec")
  speed=$(awk 'NR==4 {print $8" "$9}' progress.txt)
}

imageManager.showProgress() {
  while [ ! -z "$(ps -A | grep $pid)" ] ; do 
    imageManager.checkProcess
    clear
    if [ "$action" == "write" ] ; then
      echo "Writing image to SD-CARD..."
    fi
    if [ "$action" == "save" ] ; then
      echo "Saving image from SD-CARD..."
    fi
    echo ""
    echo -e "Time:\t $timeDone"
    echo -e "Speed:\t $speed"
    echo -e "Size:\t $sizeDone"
    sleep $update
  done
}

imageManager.checkArgs $@
imageManager.procesImage
imageManager.showProgress
