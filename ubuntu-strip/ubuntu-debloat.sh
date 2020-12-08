#!/usr/bin/bash

sudo apt update
sudo apt upgrade
# sudo snap remove canonical-livepatch
sudo apt-get remove account-plugin-facebook account-plugin-flickr account-plugin-twitter account-plugin-windows-live aisleriot \
    brltty duplicity empathy empathy-common example-content gnome-accessibility-themes gnome-contacts gnome-mahjongg gnome-mines \
    gnome-orca gnome-screensaver gnome-sudoku gnome-video-effects gnomine landscape-common libsane libsane-common python3-uno \
    rhythmbox rhythmbox-plugins rhythmbox-plugin-zeitgeist sane-utils shotwell shotwell-common telepathy-gabble telepathy-haze \
    telepathy-idle telepathy-indicator telepathy-logger telepathy-mission-control-5 telepathy-salut totem totem-common \
    totem-plugins printer-driver-brlaser printer-driver-foo2zjs printer-driver-foo2zjs-common printer-driver-m2300w \
    printer-driver-ptouch printer-driver-splix

sudo apt install gnome-control-center gnome-tweaks vim vim-scripts git gcc

# Set dark theme
gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-dark'

# Minimize on click
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'

# Show battery percentage
gsettings set org.gnome.desktop.interface show-battery-percentage true

# Needed for gnome shell extensions
sudo apt install chrome-gnome-shell

# Install restricted codecs
sudo apt install ubuntu-restricted-extras

# Enable night light
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true



# Remove all snap packages
sudo snap list|sed 1d|grep -v snapd |awk '{print $1}'|while read line
do
	sudo snap remove --purge $line
done
sudo snap remove --purge snapd
sudo apt remove --purge snapd

# Install flatpak
 

echo 'source /etc/X11/Xsession.d/20flatpak' >> ~/.bashrc
sudo apt install flatpak gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.vscodium.codium



# Remove some more stuff
sudo apt-get remove -y thunderbird rhythmbox ubuntu-web-launchers printer-driver* gnome-online-accounts whoopsie


systemctl --user mask tracker-store.service tracker-miner-fs.service tracker-miner-rss.service tracker-extract.service tracker-miner-apps.service tracker-writeback.service

tracker reset --hard
#Enable hot corners for Activity
gsettings set org.gnome.shell enable-hot-corners true


#Dont like the dock
gsettings set org.gnome.shell.extensions.dash-to-dock autohide false
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide false
