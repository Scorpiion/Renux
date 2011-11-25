#! /bin/sh
# mkcard.sh v0.5
# (c) Copyright 2009 Graeme Gregory <dp@xora.org.uk>
# Licensed under terms of GPLv2
#
# Parts of the procudure base on the work of Denys Dmytriyenko
# http://wiki.omap.com/index.php/MMC_Boot_Format
#
# 2011-11-11
# Modified by Robert Åkerblom-Andersson to be executed from createRenux.bash script

export LC_ALL=C

if [ "$eraseSdcard" == "y" ] ; then
  sudo dd if=/dev/zero of=$SD_CARD_DEV bs=1024 count=1024
fi

SIZE=`sudo fdisk -l $SD_CARD_DEV | grep Disk | grep bytes | awk '{print $5}'`

echo DISK SIZE - $SIZE bytes

CYLINDERS=`echo $SIZE/255/63/512 | bc`

echo CYLINDERS - $CYLINDERS

{
echo ,9,0x0C,*
echo ,,,-
} | sudo sfdisk -D -H 255 -S 63 -C $CYLINDERS $SD_CARD_DEV

sleep 1


if [ -x `which kpartx` ]; then
  kpartx -a ${SD_CARD_DEV}
fi

# handle various device names.
# note something like fdisk -l /dev/loop0 | egrep -E '^/dev' | cut -d' ' -f1 
# won't work due to https://bugzilla.redhat.com/show_bug.cgi?id=649572

PARTITION1=${SD_CARD_DEV}1
if [ ! -b ${PARTITION1} ]; then
  PARTITION1=${SD_CARD_DEV}p1
fi

SD_CARD_DEV_NAME=`basename $SD_CARD_DEV`
DEV_DIR=`dirname $SD_CARD_DEV`

if [ ! -b ${PARTITION1} ]; then
  PARTITION1=$DEV_DIR/mapper/${SD_CARD_DEV_NAME}p1
fi

PARTITION2=${SD_CARD_DEV}2
if [ ! -b ${PARTITION2} ]; then
  PARTITION2=${SD_CARD_DEV}p2
fi
if [ ! -b ${PARTITION2} ]; then
  PARTITION2=$DEV_DIR/mapper/${SD_CARD_DEV_NAME}p2
fi


# Create partitions 
if [ -b ${PARTITION1} ]; then
  sudo umount ${PARTITION1}
  sudo mkfs.vfat -F 32 -n "Boot" ${PARTITION1}
else
  echo "Cant find boot partition in /dev"
fi

if [ -b ${PARITION2} ]; then
  sudo umount ${PARTITION2}
  sudo mke2fs -j -L "Renux" ${PARTITION2} 
else
  echo "Cant find rootfs partition in /dev"
fi
