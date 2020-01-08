#!/bin/sh
# Daniel's Auto Rice Bootstrapping Script
# Heavily inspired by LARBS <https://larbs.xyz>
# By Daniel Krumlinde
# License: GNU GPLv3

### FUNCTIONS ###


installpkg(){
	dialog --title "DARBS Installation!" --infobox "Installing package from pacman!" 4 50
	pacman --noconfirm --needed -S "$1" >/dev/null 2>&1;
}

grepseq="\"^[PGA]*,\""

error() { clear; printf "ERROR:\\n%s\\n" "$1"; exit;}

welcomemsg() {
	dialog --title "Welcome!" --msgbox "Welcome to the first edition of DARBS" 10 60
}

getuserandpass() {
	name=$(dialog --inputbox "Enter a name for the user account." 10 60 3>&1 1>&2 2>&3 3>&1) || exit
	while ! echo "$name" grep "^[a-z_][a-z0-9_-]*$" >/dev/null 2>&1; do
		name=$(dialog --no-cancel --inputbox "Username not valid. Give a username beginning with a letter, with only lowercase letters, - or _." 10 60 3>&1 1>&2 2>&3 3>&1)
	done
	pass1=$(dialog --no-cancel --passwordbox "Enter a password for that user." 10 60 3>&1 1>&2 2>&3 3>&1)
		pass2=$(dialog --no-cancel --passwordbox "Retype password." 10 60 3>&1 1>&2 2>&3 3>&1)
		while ! [ "$pass1" = "$pass2" ]; do
			unset pass2
			pass1=$(dialog --no-cancel --passwordbox "Passwords do not match.\\n\\nEnter password again." 10 60 3>&1 1>&2 2>&3 3>&1)
			pass2=$(dialog --no-cancel --passwordbox "Retype password." 10 60 3>&1 1>&2 2>&3 3>&1)
		done ;
	}

adduserandpass() { \
	# Adds user `$name` with password $pass1.
	dialog --infobox "Adding user \"$name\"..." 4 50
	useradd -m -g wheel -s /bin/bash "$name" >/dev/null 2>&1 ||
	usermod -a -G wheel "$name" && mkdir -p /home/"$name" && chown "$name":wheel /home/"$name"
	echo "$name:$pass1" | chpasswd
	unset pass1 pass2 ;}

adduserandpass() { \
	# Adds user `$name` with password $pass1.
	dialog --infobox "Adding user \"$name\"..." 4 50
	useradd -m -g wheel -s /bin/bash "$name" >/dev/null 2>&1 ||
	usermod -a -G wheel "$name" && mkdir -p /home/"$name" && chown "$name":wheel /home/"$name"
	echo "$name:$pass1" | chpasswd
	unset pass1 pass2 ;}

aurinstallpkg(){
	dialog --title "DARBS Installation" --infobox "Installing \`$1\` from the AUR." 4 50
	sudo -u "$name" yay -S --noconfirm "$1" >/dev/null 2>&1
}
aurhelperinstall(){
	[ -f "/usr/bin/yay"] || (
	dialog --infobox "Installing yay, an AUR helper" 4 50
	cd /tmp || exit
	rm -rf /tmp/yay

	git clone https://aur.archlinux.org/yay.git
	cd yay
	sudo -u "$name" makepkg --noconfirm -si >/dev/null 2>&1
	cd /tmp || return);

}


newperms() { # Set special sudoers settings for install (or after).
	sed -i "/#LARBS/d" /etc/sudoers
	echo "$* #LARBS" >> /etc/sudoers ;
}


### THE SCRIPT ###

# Check if user is running root
#installpkg dialog || error "You must be root!"

# Display Welcome message
welcomemessage

# Get new username and password
getuserandpass

# Give warning if user already exists

# Last message before install

adduserandpass || error "Error adding username and/or password"

dialog --title "DARBS Installation" --infobox "Installing \`basedevel\` and \`git\` for installing other software." 5 70
#installpkg base-devel
#installpkg git

[ -f /etc/sudoers.pacnew ] && cp /etc/sudoers.pacnew /etc/sudoers # Just in case

newperms "%wheel ALL=(ALL) NOPASSWD: ALL"

aurhelperinstall || error "Failed to install AUR helper."

# Install dwm
aurinstallpkg dwm || error "Failed to install DWM"

# Install zsh
installpkg zsh || error "Failed to install ZSH"

# Install text editor
installpkg vim || error "Failed to install vim"

# Install firefox
installpkg firefox

# Install terminal
aurinstallpkg st || error "Failed to install Simple terminal"

# Install ranger
aurinstallpkg ranger-git || error "Failed to install ranger"

# Install image viewer

# Install PDF viewer

# Install video player

# Install htop
installpkg htop || error "Failed to install HTOP"

# Download and deploy my dotfiles


