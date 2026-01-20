#!/bin/bash
set -e

source config/variables.sh

# --- 1. FILESYSTEMS ---
mkfs.fat -F32 -n "EFI" "$EFI_PARTITION"
mkfs.btrfs -f -L "DUCKY_ROOT" "$ROOT_PARTITION"

# --- 2. SUBVOLUMES ---
mount "$ROOT_PARTITION" /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
umount /mnt

# --- 3. MOUNTING ---
mount -o compress=zstd:1,noatime,subvol=@ "$ROOT_PARTITION" /mnt
mkdir -p /mnt/{boot,home,.snapshots,etc}
mount -o compress=zstd:1,noatime,subvol=@home "$ROOT_PARTITION" /mnt/home
mount -o compress=zstd:1,noatime,subvol=@snapshots "$ROOT_PARTITION" /mnt/.snapshots
mount "$EFI_PARTITION" /mnt/boot