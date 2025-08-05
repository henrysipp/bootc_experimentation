#!/bin/bash

set -ouex pipefail

dnf5 -y rsync

# rsync system files into the container image
rsync -a /ctx/system_files/etc/ /etc/
rsync -a /ctx/system_files/usr/ /usr/


### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# COPR Repos
dnf5 -y copr enable jdxcode/mise

dnf5 install -y tmux 
dnf5 install -y code
dnf5 -y install mise

# 1Password
rpm --import https://downloads.1password.com/linux/keys/1password.asc
dnf install 1password

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
