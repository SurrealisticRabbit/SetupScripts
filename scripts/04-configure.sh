#!/bin/bash
set -e

source config/variables.sh

# --- 7. INTERNAL SCRIPT GENERATION ---
# Prepare chroot environment resources
mkdir -p /mnt/tmp/install_config

cp config/variables.sh /mnt/tmp/install_config/
# Append current runtime variables to the chroot config to ensure overrides (like from VM20G.sh) are respected
cat <<EOF >> /mnt/tmp/install_config/variables.sh

# --- Runtime Overrides ---
export DISK="$DISK"
export EFI_PARTITION="$EFI_PARTITION"
export ROOT_PARTITION="$ROOT_PARTITION"
export HOSTNAME="$HOSTNAME"
export USERNAME="$USERNAME"
EOF

cp config/refind.hook /mnt/tmp/install_config/
cp scripts/chroot_setup.sh /mnt/tmp/install_config/

# --- 8. CHROOT EXECUTION ---
chmod +x /mnt/tmp/install_config/chroot_setup.sh
arch-chroot /mnt /tmp/install_config/chroot_setup.sh
rm -rf /mnt/tmp/install_config

# --- 9. FINISH ---
echo ">> Installation Complete. Rebooting in 5s..."
sleep 5
umount -R /mnt
reboot