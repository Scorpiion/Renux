#!/bin/bash

# imageManager.bash, script to install images from file into SD-CARD 
# and to create image files from SD-CARDs
#
# Copyright (C) 2011 Robert Åkerblom-Andersson
# 
# This program is free software under the GPL license, please 
# see the license.txt and gpl.txt files in the root directory


imageManager.formatSD() {
  echo ""
  echo "Prepering SD-CARD"
  echo ""
  echo -n "Enter the path to you SD-CARD (ex. /dev/sdd): "
  read SD_CARD_DEV

  while [ "$isDeviceRight" != "y" ]; do
    clear 
    sudo fdisk -l $SD_CARD_DEV
    echo ""
    echo "OBS: All data on device $SD_CARD_DEV will be deleted!" 
    echo ""
    echo -n "Are you really sure that $SD_CARD_DEV is your SD-CARD? (y/n) "
    read isDeviceRight
    echo ""

    if [ "$isDeviceRight" != "y" ]; then
      echo -n "Enter the path to you SD-CARD (ex. /dev/sdd): "
      read SD_CARD_DEV
      echo ""
    fi
  done

  echo "Starting script to format SD-CARD..."
  formatSD.bash
}