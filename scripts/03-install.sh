#!/bin/bash
set -e

# --- 4. PRE-INSTALL CONFIGURATION ---
echo "LANG=en_GB.UTF-8" > /mnt/etc/locale.conf
echo "KEYMAP=uk" > /mnt/etc/vconsole.conf

# --- 5. INSTALLATION ---
pacstrap /mnt $(cat config/packages.txt | tr '\n' ' ')

# --- 6. SYSTEM CONFIGURATION ---
genfstab -U /mnt >> /mnt/etc/fstab