#!/bin/bash

debPackages=(\
build-essential \
subversion \
gcc-4.5 \
gperf \
util-linux \
git-core \
automake \
kpartx \
debootstrap \
qemu \
qemu-kvm-extras-static \
qemu-kvm-extras \
fakeroot \
binfmt-support \
ccache \
)
buildDepPackages=(\
gcc-4.5 \
)
failedDebPackages=()
failedbuildDepPackages=()

systemSetup.update() {
  echo ""
  echo "Updating package cache to latest version"
  sleep 1
  sudo apt-get update
}

systemSetup.installPackages() {
  echo ""
  echo "Installing packages..."
  sleep 1
  for package in "${debPackages[@]}" ; do
    sudo apt-get install $package
    if [ "$?" != "0" ] ; then 
      echo "Error: package \"$package\" failed to install, continueing with other packages..."
      failedDebPackages+=($package)
    fi
    echo ""
  done
}

systemSetup.installBuildDeps() {
  echo "Installing build dependencies..."
  sleep 1
  for package in "${buildDepPackages[@]}" ; do
    sudo apt-get build-dep $package
    if [ "$?" != "0" ] ; then 
      echo "Error: installing build dependencies for package \"$package\" failed, continuing with other packages..."
      failedbuildDepPackages+=($package)
    fi
    echo ""
  done
}

systemSetup.installStatus() {
  if [ ${#failedDebPackages[@]} -eq 0 ] ; then
    echo "All packages installed correctly!"
  else
    echo "Error: these packages did not get installed, please try and install them manually:"
    for package in "${failedDebPackages[@]}"; do
      echo " $package"
    done
  fi
}

systemSetup.buildDepStatus() {
  if [ ${#failedbuildDepPackages[@]} -eq 0 ] ; then
    echo "All build dependencies installed correctly!"
  else
    echo "Error: these build dependencies did not get installed, please try and install them manually:"
    for package in "${failedbuildDepPackages[@]}"; do
      echo " $package"
    done
  fi
}

