#!/bin/bash
set -e

# Source variables
source /tmp/install_config/variables.sh

### TIMEZONE & LOCALE
ln -sf /usr/share/zoneinfo/America/Edmonton /etc/localtime
hwclock --systohc
sed -i 's/#en_GB.UTF-8/en_GB.UTF-8/' /etc/locale.gen
locale-gen
echo "$HOSTNAME" > /etc/hostname

### NETWORK
systemctl enable NetworkManager

### SWAPFILE (BTRFS NO-COW)
truncate -s 0 /swapfile
chattr +C /swapfile
dd if=/dev/zero of=/swapfile bs=1M count=4096 status=progress
chmod 600 /swapfile
mkswap /swapfile
echo "/swapfile none swap defaults 0 0" >> /etc/fstab

### USERS
echo "root:$ROOT_PASSWORD" | chpasswd
useradd -m -G wheel -s /usr/bin/fish "$USERNAME"
echo "$USERNAME:$USER_PASSWORD" | chpasswd
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

### BOOTLOADER (REFIND)
refind-install

# Install rEFInd Theme
mkdir -p /boot/EFI/refind/themes
git clone https://github.com/Pr0cella/rEFInd-glassy.git /boot/EFI/refind/themes/rEFInd-glassy
rm -rf /boot/EFI/refind/themes/refind-theme-regular/.git
echo "include themes/rEFInd-glassy/theme.conf" >> /boot/EFI/refind/refind.conf

# Create refind_linux.conf with BTRFS subvolume flags
UCODE=""
if [ -f /boot/intel-ucode.img ]; then
    UCODE="initrd=intel-ucode.img"
elif [ -f /boot/amd-ucode.img ]; then
    UCODE="initrd=amd-ucode.img"
fi

ROOT_UUID=$(blkid -s UUID -o value "$ROOT_PARTITION")
echo "\"DuckyOS\" \"root=UUID=$ROOT_UUID rw rootflags=subvol=@ $UCODE initrd=initramfs-linux.img\"" > /boot/refind_linux.conf
echo "\"DuckyOSFallback\" \"root=UUID=$ROOT_UUID rw rootflags=subvol=@ $UCODE initrd=initramfs-linux-fallback.img\"" >> /boot/refind_linux.conf

mkdir -p /etc/pacman.d/hooks
cp /tmp/install_config/refind.hook /etc/pacman.d/hooks/refind.hook