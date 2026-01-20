#!/bin/bash

# This script partitions /dev/sda for a 20GB VM.
# 1GB EFI partition and 19GB root partition.

# Ensure you are running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Partition the disk
parted /dev/sda --script mklabel gpt
parted /dev/sda --script mkpart ESP fat32 1MiB 1025MiB
parted /dev/sda --script set 1 esp on
parted /dev/sda --script mkpart primary btrfs 1025MiB 100%

# Set variables for the installation script
export EFI_PARTITION="/dev/sda1"
export ROOT_PARTITION="/dev/sda2"
export HOSTNAME="ducky-arch"
export USERNAME="ducky"
# Add your user password here
export USER_PASSWORD="your_password"
# Add your root password here
export ROOT_PASSWORD="your_root_password"
# Add your network credentials here
export WIFI_SSID="your_wifi_ssid"
export WIFI_PASSWORD="your_wifi_password"

# Run the main installation script
bash install.sh