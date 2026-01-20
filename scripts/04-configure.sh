#!/bin/bash
set -e

source config/variables.sh

# --- 7. INTERNAL SCRIPT GENERATION ---
cat << EOF > /mnt/setup_internal.sh
#!/bin/bash
set -e

# Source variables
$(cat config/variables.sh)

### TIMEZONE & LOCALE
ln -sf /usr/share/zoneinfo/America/Edmonton /etc/localtime
hwclock --systohc
sed -i 's/#en_GB.UTF-8/en_GB.UTF-8/' /etc/locale.gen
locale-gen
echo "\$HOSTNAME" > /etc/hostname

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
echo "root:\$ROOT_PASSWORD" | chpasswd
useradd -m -G wheel -s /usr/bin/fish "\$USERNAME"
echo "\$USERNAME:\$USER_PASSWORD" | chpasswd
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

### BOOTLOADER (REFIND)
refind-install

# Create refind_linux.conf with BTRFS subvolume flags
UCODE=""
if [ -f /boot/intel-ucode.img ]; then
    UCODE="initrd=intel-ucode.img"
elif [ -f /boot/amd-ucode.img ]; then
    UCODE="initrd=amd-ucode.img"
fi

echo "\"DuckyOS\" \"root=UUID=$(blkid -s UUID -o value $ROOT_PARTITION) rw rootflags=subvol=@ \$UCODE initrd=initramfs-linux.img\"" > /boot/refind_linux.conf
echo "\"DuckyOSFallback\" \"root=UUID=$(blkid -s UUID -o value $ROOT_PARTITION) rw rootflags=subvol=@ \$UCODE initrd=initramfs-linux-fallback.img\"" >> /boot/refind_linux.conf

mkdir -p /etc/pacman.d/hooks
cat << 'HOOK' > /etc/pacman.d/hooks/refind.hook
[Trigger]
Operation=Upgrade
Type=Package
Target=refind

[Action]
Description = Updating rEFInd on ESP
When=PostTransaction
Exec=/usr/bin/refind-install
HOOK

EOF

# --- 8. CHROOT EXECUTION ---
chmod +x /mnt/setup_internal.sh
arch-chroot /mnt /setup_internal.sh
rm /mnt/setup_internal.sh

# --- 9. FINISH ---
echo ">> Installation Complete. Rebooting in 5s..."
sleep 5
umount -R /mnt
reboot