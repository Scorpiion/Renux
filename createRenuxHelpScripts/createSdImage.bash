#!/bin/bash

echo "Renux imagetool"
echo ""

createSdImage.getImageSize() {
  echo -n "Enter the desired image size (in gigabytes): "
  read imageSize

  if [ "$imageSize" == "0" ] ; then
    echo "Imagesize can't be 0"
    exit 1
  fi
}

createSdImage.createEmptyImage() {
  export imageName=$(echo "renux_${imageSize}_gb_$(date +%Y-%m-%d_%H-%M-%S).img")

  echo ""
  echo "Creating empty image file \"$imageName\"..."
  dd if=/dev/zero of=./$imageName bs=32MB count=$(($imageSize*32))
}

createSdImage.createPartitionTable() {
  echo ""
  echo "Calculating cylinder size..."
  byteSize=$(du -b $imageName | cut -f 1)
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
  } | sudo sfdisk -D -H 255 -S 63 -C $cylinderSize ./$imageName
  sleep 1
}

createSdImage.createDeviceMaps() {
  echo ""
  echo "Creating device maps from partition table"
  bootPartition=$(sudo kpartx -l ./$imageName | awk 'NR == 1 {print $1}')
  rootfsPartition=$(sudo kpartx -l ./$imageName | awk 'NR == 2 {print $1}')
  sudo kpartx -a ./$imageName
}

createSdImage.formatImage() {
  echo ""
  echo "Formating image..."
  sudo mkfs.vfat -F 32 -n "Boot" /dev/mapper/$bootPartition
  echo ""
  sudo mkfs.ext3 -j -L "Renux" /dev/mapper/$rootfsPartition
}

createSdImage.mountImage() {
  echo ""
  echo "Mounting image..."
  mkdir Boot 
  mkdir Renux
  sudo mount -t vfat /dev/mapper/loop0p1 Boot
  sudo mount -t ext3 /dev/mapper/loop0p2 Renux
}

createSdImage.installBoot() {
  echo ""
  echo "Installing files to boot partition on image..."
  for parameter in $*
  do 
    sudo cp -r $parameter/* Boot
  done
}

createSdImage.installRootfs() {
  echo ""
  echo "Installing files to rootfs partition on image..."
  for parameter in $*
  do 
    sudo cp -r $parameter/* Renux
  done
}

createSdImage.umountImage() {
  echo ""
  echo "Unmounting image..."
  sudo umount /dev/mapper/loop0p1
  sudo umount /dev/mapper/loop0p2
  sync
  sudo kpartx -d ./$imageName
  sudo rmdir Boot
  sudo rmdir Renux
}

