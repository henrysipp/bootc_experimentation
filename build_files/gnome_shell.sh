#!/bin/bash

dnf5 -y install gnome-tweaks 
dnf5 -y install gnome-extensions-app curl
dnf5 -y install gnome-shell-extension-appindicator \
    gnome-shell-extension-blur-my-shell \
    gnome-shell-extension-auto-move-windows

# Install Hot Edge from source (not packaged in repos).
HOTEDGE_UUID="hotedge@jonathan.jdoda.ca"
HOTEDGE_DIR="/usr/share/gnome-shell/extensions/${HOTEDGE_UUID}"
HOTEDGE_TARBALL="/tmp/hotedge.tar.gz"
HOTEDGE_SRC="/tmp/hotedge-main"

curl -L -o "${HOTEDGE_TARBALL}" https://github.com/henrysipp/hotedge/archive/refs/heads/main.tar.gz
rm -rf "${HOTEDGE_SRC}" "${HOTEDGE_DIR}"
mkdir -p "${HOTEDGE_DIR}"
tar -xzf "${HOTEDGE_TARBALL}" -C /tmp
cp -a "${HOTEDGE_SRC}/." "${HOTEDGE_DIR}/"
if [ -d "${HOTEDGE_DIR}/schemas" ]; then
  glib-compile-schemas "${HOTEDGE_DIR}/schemas"
fi
rm -rf "${HOTEDGE_TARBALL}" "${HOTEDGE_SRC}"

# Compile schemas to ensure they're valid after GNOME shell setup
echo "Compiling schemas after GNOME shell setup..."
glib-compile-schemas /usr/share/glib-2.0/schemas
