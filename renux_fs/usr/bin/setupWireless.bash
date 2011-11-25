#!/bin/bash

# Script to setup WPA2 wireless connections
# Copyright (C) 2011 Robert Åkerblom-Andersson
#·
# This program is free software under the GPL license, please· 
# see the license.txt and gpl.txt files in the root directory 

configFile=/etc/wpa_supplicant.conf

echo "This script only works if you run it as root..."
echo ""

read -p "Enter interface: " interface
read -p "Enter network ssid: " ssid
read -p "Enter netword password: " -s password
echo ""

wpa_passphrase $ssid $password > /tmp/wpa.txt
grep -v '#' /tmp/wpa.txt | grep 'ssid' > /tmp/wpa_ssid.txt
grep -v '#' /tmp/wpa.txt | grep 'psk' > /tmp/wpa_psk.txt

# Remove posible old run file
echo "Checking for file /var/run/wpa_supplicant/$interface "
if [ -a  /var/run/wpa_supplicant/${interface} ] 
then 
  echo "Removing file /var/run/wpa_supplicant/$interface"
  rm -rf /var/run/wpa_supplicant/$interface 
fi

# Kill existing wpa_supplicant deamons
for i in range 0, $(ps -A | grep wpa_supplicant | wc -l); do killall wpa_supplicant; done

echo "Creating $configFile file..."
cat > $configFile << "EOF"
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=sys

network={
EOF

cat /tmp/wpa_ssid.txt >> $configFile 
cat /tmp/wpa_psk.txt >> $configFile 

cat >> $configFile << "EOF"
        proto=RSN
        key_mgmt=WPA-PSK
        pairwise=CCMP TKIP
        group=CCMP TKIP
}

EOF

rm -rf /tmp/wpa.txt
rm -rf /tmp/wpa_ssid.txt
rm -rf /tmp/wpa_psk.txt

echo "Restarting interface..."
ifconfig $interface down
ifconfig $interface up

echo "Setting wlan settings..."
iwconfig $interface essid $ssid key on enc on mode managed

echo "Starting wpa deamon..."
wpa_supplicant -B -D wext,nl80211 -i $interface -c $configFile

echo "Sleeping 10 seconds before asking for an IP address..."
sleep  10

echo "Asking for address from dhcp..."
dhclient $interface

# Restrict permissions /etc/network/interfaces to prevent pre-shared key (PSK) attack
chmod 0600 /etc/network/interfaces

