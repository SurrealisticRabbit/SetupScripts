#!/bin/bash
set -e

source config/variables.sh

# Ensure you are running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Partition the disk
parted "$DISK" --script mklabel gpt
parted "$DISK" --script mkpart ESP fat32 1MiB 1025MiB
parted "$DISK" --script set 1 esp on
parted "$DISK" --script mkpart primary btrfs 1025MiB 100%