#!/usr/bin/env bash
#  ╦═╗╦╔═╗╔═╗  ╦╔╗╔╔═╗╔╦╗╔═╗╦  ╦  ╔═╗╦═╗
#  ╠╦╝║║  ║╣   ║║║║╚═╗ ║ ╠═╣║  ║  ║╣ ╠╦╝
#  ╩╚═╩╚═╝╚═╝  ╩╝╚╝╚═╝ ╩ ╩ ╩╩═╝╩═╝╚═╝╩╚═
#	Script to install bspwm and other tool config dotfiles
# Author: z0mbi3
# Modifier: allenmagic
#	raw_url: https://github.com/gh0stzk
# modifi_url: https://github.com/allenmagic


CRE=$(tput setaf 1)
CYE=$(tput setaf 3)
CGR=$(tput setaf 2)
CBL=$(tput setaf 4)
BLD=$(tput bold)
CNC=$(tput sgr0)

backup_folder=~/.RiceBackup
date=$(date +%Y%m%d-%H%M%S)

logo () {
	
	local text="${1:?}"
	echo -en "                                  
	               %%%                
	        %%%%%//%%%%%              
	      %%************%%%           
	  (%%//############*****%%
	%%%%%**###&&&&&&&&&###**//
	%%(**##&&&#########&&&##**
	%%(**##*****#####*****##**%%%
	%%(**##     *****     ##**
	   //##   @@**   @@   ##//
	     ##     **###     ##
	     #######     #####//
	       ###**&&&&&**###
	       &&&         &&&
	       &&&////   &&
	          &&//@@@**
	            ..***                
			  z0mbi3 Dotfiles\n\n"
    printf ' %s [%s%s %s%s %s]%s\n\n' "${CRE}" "${CNC}" "${CYE}" "${text}" "${CNC}" "${CRE}" "${CNC}"
}

########## ---------- You must not run this as root ---------- ##########

if [ "$(id -u)" = 0 ]; then
    echo "This script MUST NOT be run as root user."
    exit 1
fi

########## ---------- Welcome ---------- ##########

logo "Welcome!"
printf '%s%sThis script will check if you have the necessary dependencies, \n1. and if not, it will install them. \n2. And then ,it will clone the RICE in your HOME directory.\n3. After that, it will create a secure backup of your files, \n4. and then copy the new files to your computer.\n\nMy dotfiles DO NOT modify any of your system configurations.\nYou will be prompted for your root password to install missing dependencies and/or to switch to zsh shell if its not your default.\n\nThis script doesnt have the potential power to break your system, it only copies files from my repository to your HOME directory.%s\n\n' "${BLD}" "${CRE}" "${CNC}"

while true; do
	read -rp " Do you wish to continue? [y/N]: " yn
		case $yn in
			[Yy]* ) break;;
			[Nn]* ) exit;;
			* ) printf " Error: just write 'y' or 'n'\n\n";;
		esac
    done
clear

########## ---------- Install packages ---------- ##########

logo "Installing needed packages.."

dependencias=(build-essential rust-all rust-coreutils bspwm polybar sxhkd \
			  alacritty brightnessctl dunst rofi lsd librust-gdk-dev \
			  jq policykit-1-gnome git playerctl mpd xclip \
			  bat curl ranger mpc picom xdo xdotool jgmenu \
			  feh ueberzug maim pamixer webp libwebp-dev xdg-user-dirs \
			  webp-pixbuf-loader xorg physlock papirus-icon-theme \
			  fonts-jetbrains-mono fonts-inconsolata lightdm x11-xserver-utils \
			  zsh zsh-autosuggestions zsh-syntax-highlighting x11-utils)

is_installed() {
  dpkg -l "$1" &> /dev/null
  return $?
}

printf "%s%sChecking for required packages...%s\n" "${BLD}" "${CBL}" "${CNC}"
for paquete in "${dependencias[@]}"
do
  if ! is_installed "$paquete"; then
    sudo apt-get install -y "$paquete" 
    printf "\n"
  else
    printf '%s%s is already installed on your system!%s\n' "${CGR}" "$paquete" "${CNC}"
    sleep 1
  fi
done
sleep 3
clear


########## ---------- Preparing Folders ---------- ##########

# Verifica si el archivo user-dirs.dirs no existe en ~/.config
	if [ ! -e "$HOME/.config/user-dirs.dirs" ]; then
		xdg-user-dirs-update
		echo "Creating xdg-user-dirs"
	fi
sleep 2 
clear

########## ---------- Cloning the Rice! ---------- ##########

logo "Downloading dotfiles"

repo_url="https://github.com/allenmagic/bspdotfiles.git"
repo_dir="$HOME/dotfiles"

# Verifica si el directorio del repositorio ya existe y, si es así, lo elimina
	if [ -d "$repo_dir" ]; then
		printf "Removing existing dotfiles repository\n"
		rm -rf "$repo_dir"
	fi

# Clona el repositorio
printf "Cloning dotfiles from %s\n" "$repo_url"
git clone --depth=1 "$repo_url" "$repo_dir"

sleep 2
clear

########## ---------- Backup files ---------- ##########

logo "Backup files"
printf "Backup files will be stored in %s%s%s/.RiceBackup%s \n\n" "${BLD}" "${CRE}" "$HOME" "${CNC}"
sleep 10

if [ ! -d "$backup_folder" ]; then
  mkdir -p "$backup_folder"
fi

for folder in bspwm alacritty picom rofi eww sxhkd dunst polybar ncmpcpp nvim ranger zsh mpd; do
  if [ -d "$HOME/.config/$folder" ]; then
    mv "$HOME/.config/$folder" "$backup_folder/${folder}_$date"
    echo "$folder folder backed up successfully at $backup_folder/${folder}_$date"
  else
    echo "The folder $folder does not exist in $HOME/.config/"
  fi
done

for folder in chrome; do
  if [ -d "$HOME"/.mozilla/firefox/*.default-release/$folder ]; then
    mv "$HOME"/.mozilla/firefox/*.default-release/$folder "$backup_folder"/${folder}_$date
    echo "$folder folder backed up successfully at $backup_folder/${folder}_$date"
  else
    echo "The folder $folder does not exist in $HOME/.mozilla/firefox/"
  fi
done

for file in user.js; do
  if [ -e "$HOME"/.mozilla/firefox/*.default-release/$file ]; then
    mv "$HOME"/.mozilla/firefox/*.default-release/$file "$backup_folder"/${file}_$date
    echo "$file file backed up successfully at $backup_folder/${file}_$date"
  else
    echo "The file $file does not exist in $HOME/.mozilla/firefox/"
  fi
done

[ -f ~/.zshrc ] && mv ~/.zshrc ~/.RiceBackup/.zshrc-backup-"$(date +%Y.%m.%d-%H.%M.%S)"

printf "%s%sDone!!%s\n\n" "${BLD}" "${CGR}" "${CNC}"
sleep 5

########## ---------- Copy the Rice! ---------- ##########

logo "Installing dotfiles.."
printf "Copying files to respective directories..\n"

[ ! -d ~/.config ] && mkdir -p ~/.config
[ ! -d ~/.local/bin ] && mkdir -p ~/.local/bin
[ ! -d ~/.local/share/applications ] && mkdir -p ~/.local/share/applications
[ ! -d ~/.local/share/fonts ] && mkdir -p ~/.local/share/fonts
[ ! -d ~/.local/share/asciiart ] && mkdir -p ~/.local/share/asciiart

for archivos in ~/dotfiles/config/*; do
  cp -R "${archivos}" ~/.config/
  if [ $? -eq 0 ]; then
	printf "%s%s%s folder copied succesfully!%s\n" "${BLD}" "${CGR}" "${archivos}" "${CNC}"
	sleep 1
  else
	printf "%s%s%s failed to been copied, you must copy it manually%s\n" "${BLD}" "${CRE}" "${archivos}" "${CNC}"
	sleep 1
  fi
done

for archivos in ~/dotfiles/misc/bin/*; do
  cp -R "${archivos}" ~/.local/bin/
  if [ $? -eq 0 ]; then
	printf "%s%s%s file copied succesfully!%s\n" "${BLD}" "${CGR}" "${archivos}" "${CNC}"
	sleep 1
  else
	printf "%s%s%s failed to been copied, you must copy it manually%s\n" "${BLD}" "${CRE}" "${archivos}" "${CNC}"
	sleep 1
  fi
done

for archivos in ~/dotfiles/misc/applications/*; do
  cp -R "${archivos}" ~/.local/share/applications/
  if [ $? -eq 0 ]; then
	printf "%s%s%s file copied succesfully!%s\n" "${BLD}" "${CGR}" "${archivos}" "${CNC}"
	sleep 1
  else
	printf "%s%s%s failed to been copied, you must copy it manually%s\n" "${BLD}" "${CRE}" "${archivos}" "${CNC}"
	sleep 1
  fi
done

for archivos in ~/dotfiles/misc/fonts/*; do
  cp -R "${archivos}" ~/.local/share/fonts/
  if [ $? -eq 0 ]; then
	printf "%s%s%s copied succesfully!%s\n" "${BLD}" "${CGR}" "${archivos}" "${CNC}"
	sleep 1
  else
	printf "%s%s%s failed to been copied, you must copy it manually%s\n" "${BLD}" "${CRE}" "${archivos}" "${CNC}"
	sleep 1
  fi
done

for archivos in ~/dotfiles/misc/asciiart/*; do
  cp -R "${archivos}" ~/.local/share/asciiart/
  if [ $? -eq 0 ]; then
	printf "%s%s%s file copied succesfully!%s\n" "${BLD}" "${CGR}" "${archivos}" "${CNC}"
	sleep 1
  else
	printf "%s%s%s failed to been copied, you must copy it manually%s\n" "${BLD}" "${CRE}" "${archivos}" "${CNC}"
	sleep 1
  fi
done

for archivos in ~/dotfiles/misc/firefox/*; do
  cp -R "${archivos}" ~/.mozilla/firefox/*.default-release/
  if [ $? -eq 0 ]; then
	printf "%s%s%s folder copied succesfully!%s\n" "${BLD}" "${CGR}" "${archivos}" "${CNC}"
	sleep 1
  else
	printf "%s%s%s failed to been copied, you must copy it manually%s\n" "${BLD}" "${CRE}" "${archivos}" "${CNC}"
	sleep 1
  fi
done

cp -f "$HOME"/dotfiles/home/.zshrc "$HOME"
fc-cache -rv >/dev/null 2>&1
printf "%s%sFiles copied succesfully!!%s\n" "${BLD}" "${CGR}" "${CNC}"
sleep 3

########## ---------- Installing tdrop,eww,xqp & stalonetray ---------- ##########

logo "installing tdrop,eww,xqp & stalonetray"
# Intalling tdrop for scratchpads
	if command -v tdrop >/dev/null 2>&1; then
		printf "\n%s%sTdrop is already installed%s\n" "${BLD}" "${CGR}" "${CNC}"
	else
		printf "\n%s%sInstalling tdrop, this should be fast!%s\n" "${BLD}" "${CBL}" "${CNC}"
		{
			cd "$HOME" || exit
			git clone https://github.com/noctuid/tdrop.git
			cd tdrop || exit
			make && sudo make install
		} && {
			cd "$HOME" || exit
		} 
	fi


# Installing Eww
	if command -v eww >/dev/null 2>&1; then 
		printf "\n%s%sEww is already installed%s\n" "${BLD}" "${CGR}" "${CNC}"
	else
		printf "\n%s%sInstalling Eww, this could take 10 mins or more.%s\n" "${BLD}" "${CBL}" "${CNC}"
		{
			cd "$HOME" || exit
			git clone https://github.com/elkowar/eww
			cd eww || exit
			curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain none -y
			cargo build --release --no-default-features --features x11
			sudo install -m 755 "$HOME/eww/target/release/eww" -t /usr/bin/
		} && {
			cd "$HOME" || exit
		} || {
        printf "\n%s%sFailed to install Eww. You may need to install it manually%s\n" "${BLD}" "${CRE}" "${CNC}"
    }
fi

# Installing stalonetray
	if command -v stalonetray >/dev/null 2>&1; then 
		printf "\n%s%sstalonetray is already installed%s\n" "${BLD}" "${CGR}" "${CNC}"
	else
		printf "\n%s%sInstalling stalonetray, this could take 10 mins or more.%s\n" "${BLD}" "${CBL}" "${CNC}"
		{
			cd "$HOME" || exit
			git clone https://github.com/kolbusa/stalonetray.git
			cd stalonetray || exit
			sudo apt install -y autoconf automake docbook-xsl libxpm-dev libx11-dev xsltproc
			aclocal && autoheader && autoconf && automake --add-missing
			./configure
			make && sudo make install
		} && {
			cd "$HOME" || exit
			rm -rf {tdrop,.cargo,eww,stalonetray}
		} || {
        printf "\n%s%sFailed to install stalonetray. You may need to install it manually%s\n" "${BLD}" "${CRE}" "${CNC}"
    }
fi

########## ---------- Enabling MPD service ---------- ##########

logo "Enabling mpd service"

# Verifica si el servicio mpd está habilitado a nivel global (sistema)
	if systemctl is-enabled --quiet mpd.service; then
		printf "\n%s%sDisabling and stopping the global mpd service%s\n" "${BLD}" "${CBL}" "${CNC}"
		sudo systemctl stop mpd.service
		sudo systemctl disable mpd.service
	fi

printf "\n%s%sEnabling and starting the user-level mpd service%s\n" "${BLD}" "${CYE}" "${CNC}"
systemctl --user enable --now mpd.service

printf "%s%sDone!!%s\n\n" "${BLD}" "${CGR}" "${CNC}"
sleep 2

########## --------- Changing shell to zsh ---------- ##########

logo "Changing default shell to zsh"

	if [[ $SHELL != "/usr/bin/zsh" ]]; then
		printf "\n%s%sChanging your shell to zsh. Your root password is needed.%s\n\n" "${BLD}" "${CYE}" "${CNC}"
		# Cambia la shell a zsh
		chsh -s /usr/bin/zsh
		printf "%s%sShell changed to zsh. Please reboot.%s\n\n" "${BLD}" "${CGR}" "${CNC}"
	else
		printf "%s%sYour shell is already zsh\nGood bye! installation finished, now reboot%s\n" "${BLD}" "${CGR}" "${CNC}"
	fi
zsh
