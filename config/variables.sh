#!/bin/bash

# Disk to partition
export DISK="/dev/sda"

# Partitions
export EFI_PARTITION="/dev/sda1"
export ROOT_PARTITION="/dev/sda2"

# User settings
export HOSTNAME="ducky-arch"
export USERNAME="ducky"
export USER_PASSWORD="your_password"
export ROOT_PASSWORD="your_root_password"

# Network settings
if [ -f config/SSID ] && [ -f config/PASS ]; then
    export WIFI_SSID=$(cat config/SSID)
    export WIFI_PASSWORD=$(cat config/PASS)
else
    export WIFI_SSID=""
    export WIFI_PASSWORD=""
fi
