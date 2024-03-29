#!/bin/bash

echo "Is this a laptop?"
select yn in "Yes" "No"; do
	case $yn in
	Yes)
		sudo pacman -S acpi acpi_call tlp bluez bluez-utils brightnessctl wireless_tools
		systemctl enable bluetooth.service
		systemctl enable tlp
		break
		;;
	No) break ;;
	esac
done

#Hook that deletes pacman cache
# mkdir /etc/pacman.d/hooks && touch /etc/pacman.d/clean_pacman_cache.hook
# tee -a /etc/pacman.d/hooks/clean_pacman_cache.hook << END
# [Trigger]
# Operation = Upgrade
# Operation = Install
# Operation = Remove
# Type = Package
# Target = *
# [Action]
# Description = Cleaning pacman cache...
# When = PostTransaction
# Exec = /usr/bin/paccache -r
# END

touch "$HOME"/.priv

#enabling multilib
sudo echo '[multilib]' >>/etc/pacman.conf
sudo echo 'Include = /etc/pacman.d/mirrorlist' >>/etc/pacman.conf
sudo pacman -Sy

#enable parallel downloads
sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf

#install basic packages
sudo pacman --needed -S - <"$HOME"/Arch-install/basicpacman.txt

#create basic directories
xdg-user-dirs-update

#YAY installation. NINGUN PAQUETE AUR QUEDÓ INSTALADO CORRECTAMENTE
git clone https://aur.archlinux.org/yay-bin.git "$HOME"/yay-bin
cd "$HOME"/yay-bin
makepkg -si

# yay -S $(tr -s '\n' ' ' <"$HOME"/Arch-install/aurpackages.txt)
# yay -S $(cat ~/Arch-install/aurpackages.txt)

#pipewire setup
#systemctl --user daemon-reload
#systemctl --user --now disable pulseaudio.service pulseaudio.socket

#oh my zsh, do not execute with root
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
#oh my zsh plugins
cd "$HOME"/.oh-my-zsh/plugins/
git clone https://github.com/Aloxaf/fzf-tab "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/fzf-tab
git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting

#tmux plugin manager
git clone https://github.com/tmux-plugins/tpm "$HOME"/.tmux/plugins/tpm

#ranger plugins
#ranger icons
git clone https://github.com/alexanderjeurissen/ranger_devicons "$HOME"/.config/ranger/plugins/ranger_devicons

#custom .desktop
mkdir "$HOME"/.local/share/applications
touch "$HOME"/.local/share/applications/steamgamemode.desktop
tee -a "$HOME"/.local/share/applications/steamgamemode.desktop <<END
[Desktop Entry]
Name=Steam gamemode
Comment= Gamemode
Exec=gamemoderun steam-runtime
Icon=steam
Terminal=false
Type=Application
Categories=Game;
END

#default applications
handlr set inode/directory thunar.desktop

#El siguiente comando es redundante porque ohmyzsh pregunta si quiero hacer a zsh el shell predeterminado
#chsh -s $(which zsh)

#Para agregar LTS al GRUB (no sé si así funciona)
# sudo grub-mkconfig -o /boot/grub/grub.cfg
# sudo grub-install --efi-directory=/boot

#Stow
git clone https://github.com/pipe99g/dotfiles "$HOME"/dotfiles
cd "$HOME"/dotfiles
mkdir "$HOME"/.config/joplin && rm "$HOME"/.zshrc "$HOME"/.bashrc "$HOME"/.bash_profile "$HOME"/.config/atuin/config.toml && stow *

#tmux sessions
chmod u+x "$HOME"/dotfiles/scripts/scripts/t
sudo ln -s "$HOME"/scripts/t /usr/bin/t

#enable services
systemctl --user enable --now pipewire.socket
systemctl --user enable --now pipewire-pulse.socket
systemctl --user enable --now wireplumber.service
systemctl enable paccache.timer
systemctl enable ufw.service
systemctl enable archlinux-keyring-wkd-sync.timer
systemctl enable cups.service
systemctl enable cronie.service
#si se usa ssd
systemctl enable fstrim.timer
systemctl enable grub-btrfsd
