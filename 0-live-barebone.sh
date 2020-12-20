#!/bin/bash

# Update the system clock
timedatectl set-ntp true

# Partition the disks
# /dev/sda1 EFI System
# /dev/sda2 root

# Format the partitions
pacman -S --noconfirm gptfdisk btrfs-progs
lsblk
read -p "\nPlease enter disk: (example /dev/sda)" DISK

# disk prep
sgdisk -Z ${DISK} # zap all on disk
sgdisk -a 2048 -o ${DISK} # new gpt disk 2048 alignment
# create partitions
sgdisk -n 1:0:+1000M ${DISK} # partition 1 (UEFI SYS), default start block, 1GB
sgdisk -n 2:0:0     ${DISK} # partition 2 (Root), default start, remaining
# set partition types
sgdisk -t 1:ef00 ${DISK}
sgdisk -t 2:8300 ${DISK}
# label partitions
sgdisk -c 1:"UEFISYS" ${DISK}
sgdisk -c 2:"ROOT" ${DISK}
# make filesystems
mkfs.fat -F32 -n "UEFISYS" "${DISK}1"
mkfs.ext4 -L "ROOT" "${DISK}2"
# mount target
mkdir /mnt
mount -t ext4 "${DISK}2" /mnt
mkdir /mnt/boot
mkdir /mnt/boot/efi
mount -t vfat "${DISK}1" /mnt/boot/

# Install essential packages
pacstrap /mnt base linux base-devel linux-lts linux-firmware nano git sudo --noconfirm --needed

# Generate File System Table
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot + Time zone
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Africa/Casablanca /etc/localtime
arch-chroot /mnt hwclock --systohc

# Localization
arch-chroot /mnt echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
arch-chroot /mnt locale-gen
arch-chroot /mnt echo "LANG=en_US.UTF-8" > /etc/locale.conf
arch-chroot /mnt localectl --no-ask-password set-keymap us

# Network configuration
read -p "Please enter Hostname: " host_name
arch-chroot /mnt echo $host_name >> /etc/hostname
arch-chroot /mnt cat <<EOF > /etc/hosts
127.0.0.1	localhost
::1		localhost
127.0.1.1	$host_name.localdomain	$host_name
EOF
arch-chroot /mnt pacman -S networkmanager dhclient --noconfirm --needed
arch-chroot /mnt systemctl enable --now NetworkManager

# Initramfs
arch-chroot /mnt mkinitcpio -P

# Set Root password
echo "Set Root Password"
arch-chroot /mnt passwd

# Install Grub
sed -i 's/^#Color/Color\nILoveCandy/' /etc/pacman.conf # Enable Pacman Easter Egg
arch-chroot /mnt pacman -S grub efibootmgr os-prober amd-ucode intel-ucode --noconfirm --needed
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# Add a User
read -p "Please enter username: " username
arch-chroot /mnt useradd -m $username -G wheel,games,audio,disk,optical,storage,video
arch-chroot /mnt passwd $username
arch-chroot /mnt sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
arch-chroot /mnt nano /etc/sudoers

# Unmount drives and reboot
umount -R /mnt
umount -R /mnt/boot
reboot
