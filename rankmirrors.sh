pacman -Sy --noconfirm reflector
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
reflector --latest 50 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist
