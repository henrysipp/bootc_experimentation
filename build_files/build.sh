#!/bin/bash

set -ouex pipefail


mkdir -p /var/opt /var/roothome

dnf5 -y install rsync
dnf5 -y install 'dnf5-command(copr)'
dnf5 -y install dnf5-plugins

# rsync system files into the container image
rsync -rvK /ctx/system_files/ /
# rsync -a /ctx/system_files/usr/ /usr/

# dnf check-update
### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

dnf5 -y install gnome-tweaks 

# COPR Repos
dnf5 -y config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo

dnf5 -y install git
dnf5 -y install gh --repo gh-cli
dnf5 -y install tmux 
dnf5 -y install code

dnf5 -y copr enable jdxcode/mise
dnf5 -y install mise
dnf5 -y copr disable jdxcode/mise

rpm --import https://downloads.1password.com/linux/keys/1password.asc
dnf5 install -y 1password 1password-cli

#### Example for enabling a System Unit File

# Install 1Password
bash /ctx/build_files/1password.sh

systemctl enable podman.socket
