#!/bin/bash

set -ouex pipefail
mkdir -p /var/opt /var/roothome


# Plugins
dnf5 -y install rsync
dnf -y install curl tar ca-certificates && update-ca-trust
dnf5  -y install 'dnf5-command(copr)'
dnf5 -y install 'dnf5-command(config-manager)'
dnf5 -y install dnf5-plugins

# rsync system files into the container image
# rsync -rvK /ctx/system_files/ /


# COPR Repos
dnf5 -y config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo
dnf5 -y copr enable bazzite-org/bazzite
dnf5 -y copr enable jdxcode/mise

dnf5 -y install podman podman-compose
dnf5 -y install git
dnf5 -y install gh --repo gh-cli
dnf5 -y install tmux 
# dnf5 -y install code

# Dependencies for erlang mise install, probably useful for others
dnf5 -y install gcc gcc-c++ make autoconf automake openssl-devel ncurses-devel

# dnf5 install fedora-workstation-repositories
# dnf5 config-manager setopt google-chrome.enabled=1
# # dnf5 config-manager --set-enabled google-chrome
# dnf5 -y install google-chrome-stable

dnf5 config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo
dnf5 -y install tailscale
dnf5 -y install mise
dnf5 -y install cifs-utils

dnf5 -y copr disable jdxcode/mise

rpm --import https://downloads.1password.com/linux/keys/1password.asc
dnf5 install -y 1password 1password-cli

bash /ctx/build_files/1password.sh
bash /ctx/build_files/hypr.sh
# bash /ctx/build_files/gnome_shell.sh


# Services
systemctl enable podman.socket
systemctl enable tailscaled

# Create mount point and add SMB mount to fstab
# Use a different approach - create in /var/mnt instead
mkdir -p /var/mnt/media
chmod 755 /var/mnt/media
echo "//tower/media /var/mnt/media cifs guest,uid=1000,gid=1000,iocharset=utf8,file_mode=0777,dir_mode=0777 0 0" >> /etc/fstab
