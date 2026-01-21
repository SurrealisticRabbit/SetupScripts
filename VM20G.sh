#!/bin/bash
set -e

# --- Configuration for VM 20G ---
export DISK="/dev/sda"
export EFI_PARTITION="/dev/sda1"
export ROOT_PARTITION="/dev/sda2"
export HOSTNAME="ducky-vm"

# --- Execution ---
echo "Press Enter to continue..."
read
./install.sh
