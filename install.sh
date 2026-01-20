#!/bin/zsh
set -e

# --- PRE-FLIGHT CHECKS ---
if [[ -z "$EFI_PARTITION" || -z "$ROOT_PARTITION" ]]; then
    echo "Error: EFI_PARTITION or ROOT_PARTITION not set."
    exit 1
fi

echo ">> DuckyOS Installer Started"
echo ">> EFI:  $EFI_PARTITION"
echo ">> ROOT: $ROOT_PARTITION"

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

# --- 4. PRE-INSTALL CONFIGURATION ---
echo "LANG=en_GB.UTF-8" > /mnt/etc/locale.conf
echo "KEYMAP=uk" > /mnt/etc/vconsole.conf

# --- 5. INSTALLATION ---
pacstrap /mnt base linux linux-firmware base-devel btrfs-progs refind \
    zsh fish bash-completion vim git networkmanager \
    intel-ucode amd-ucode man-db man-pages

# --- 6. SYSTEM CONFIGURATION ---
genfstab -U /mnt >> /mnt/etc/fstab

# --- 7. INTERNAL SCRIPT GENERATION ---
cat << EOF > /mnt/setup_internal.sh
#!/bin/bash
set -e

### TIMEZONE & LOCALE
ln -sf /usr/share/zoneinfo/America/Edmonton /etc/localtime
hwclock --systohc
sed -i 's/#en_GB.UTF-8/en_GB.UTF-8/' /etc/locale.gen
locale-gen
echo "$HOSTNAME" > /etc/hostname

### NETWORK
systemctl enable NetworkManager
systemctl start NetworkManager
if [ -n "$WIFI_SSID" ] && [ -n "$WIFI_PASSWORD" ]; then
    nmcli dev wifi connect "$WIFI_SSID" password "$WIFI_PASSWORD"
fi

### SWAPFILE (BTRFS NO-COW)
truncate -s 0 /swapfile
chattr +C /swapfile
btrfs property set /swapfile compression none
dd if=/dev/zero of=/swapfile bs=1M count=4096 status=progress
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile none swap defaults 0 0" >> /etc/fstab

### USERS
echo "root:$ROOT_PASSWORD" | chpasswd
useradd -m -G wheel -s /usr/bin/fish "$USERNAME"
echo "$USERNAME:$USER_PASSWORD" | chpasswd
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

### BOOTLOADER (REFIND)
refind-install

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
