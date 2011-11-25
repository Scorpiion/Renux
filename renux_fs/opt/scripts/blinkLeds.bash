#!/bin/bash

while [ 1 ] ; do
echo 0 > /sys/class/leds/beagleboard\:\:usr0/brightness
echo 0 > /sys/class/leds/beagleboard\:\:usr1/brightness
sleep 1
echo 1 > /sys/class/leds/beagleboard\:\:usr0/brightness
echo 1 > /sys/class/leds/beagleboard\:\:usr1/brightness
done

