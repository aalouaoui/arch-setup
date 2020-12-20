# Install paru
sudo pacman -S base-devel --noconfirm --needed
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin
makepkg -si
cd ..
rm -rf paru-bin

# Install Xorg and Intel GPU Driver
sudo pacman -S xf86-video-intel xorg numlockx --noconfirm --needed

# Install terminals
sudo pacman -S alacritty xterm --noconfirm --needed # xterm is just for compatibility with apps hardcoded to use xterm

# Install Qtile
sudo pacman -S qtile --noconfirm

# Disable Mouse Accelaration in X11
sudo cat <<EOF > /etc/X11/xorg.conf.d/50-mouse-acceleration.conf
Section "InputClass"
	Identifier "My Mouse"
	Driver "libinput"
	MatchIsPointer "yes"
	Option "AccelProfile" "flat"
	Option "AccelSpeed" "-0.4"
EndSection
EOF

# Install lightdm
sudo pacman -S lightdm lightdm-webkit2-greeter --noconfirm
# in [Seat:*] set greeter-session=lightdm-webkit2-greeter
# also set greeter-setup-script=/usr/bin/numlockx on
sudo nano /etc/lightdm/lightdm.conf
sudo systemctl enable lightdm

# Install some apps
sudo pacman -S network-manager-applet nitrogen thunar --noconfirm
