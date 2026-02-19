#!/bin/bash

set -ouex pipefail
mkdir -p /var/opt /var/roothome


# Plugins
dnf5 -y install rsync
dnf -y install curl tar ca-certificates && update-ca-trust
dnf5  -y install 'dnf5-command(copr)'
dnf5 -y install 'dnf5-command(config-manager)'
dnf5 -y install dnf5-plugins
dnf5 -y install firefox
dnf5 -y install chromium
dnf5 -y install wtype

# rsync system files into the container image
rsync -rvK /ctx/system_files/ /
dconf update

rpm --import https://downloads.1password.com/linux/keys/1password.asc
dnf5 install -y 1password 1password-cli

bash /ctx/build_files/1password.sh

# Install Slack from Slack's first-party RPM URL discovered from official pages
SLACK_RPM_URL="$(
  {
    curl -fsSL "https://slack.com/downloads/instructions/linux?build=rpm&ddl=1" || true
    curl -fsSL "https://slack.com/downloads/linux" || true
  } | grep -Eo "https://downloads\\.slack-edge\\.com[^\"'[:space:]<>]+\\.rpm" | head -n1
)"
echo "Resolved Slack RPM URL: ${SLACK_RPM_URL}"
test -n "${SLACK_RPM_URL}"
curl -fsSL -o /tmp/slack.rpm "${SLACK_RPM_URL}"
dnf5 install -y /tmp/slack.rpm
rm -f /tmp/slack.rpm

# Create mount point and add SMB mount to fstab
# Use a different approach - create in /var/mnt instead
# mkdir -p /var/mnt/media
# chmod 755 /var/mnt/media
# echo "//tower/media /var/mnt/media cifs guest,uid=1000,gid=1000,iocharset=utf8,file_mode=0777,dir_mode=0777 0 0" >> /etc/fstab
