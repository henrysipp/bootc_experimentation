#!/bin/bash

set -ouex pipefail
mkdir -p /var/opt /var/roothome


# Plugins
dnf5 -y install rsync
dnf5 -y install 'dnf5-command(copr)'
dnf5 -y install dnf5-plugins

# rsync system files into the container image
rsync -rvK /ctx/system_files/ /
dconf update

# COPR Repos
dnf5 -y config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo
dnf5 -y copr enable bazzite-org/bazzite

dnf5 -y install git
dnf5 -y install gh --repo gh-cli
dnf5 -y install tmux 
dnf5 -y install code

dnf5 -y copr enable jdxcode/mise
dnf5 -y install mise
dnf5 -y copr disable jdxcode/mise

rpm --import https://downloads.1password.com/linux/keys/1password.asc
dnf5 install -y 1password 1password-cli

bash /ctx/build_files/1password.sh
bash /ctx/build_files/gnome_shell.sh

# Update dconf database to include our custom settings
dconf update

# Services
systemctl enable podman.socket
