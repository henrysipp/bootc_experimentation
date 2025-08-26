#!/bin/bash

dnf5 -y install gnome-tweaks 
dnf5 -y install gnome-extensions-app 
dnf5 -y install gnome-shell-extension-appindicator \
    gnome-shell-extension-blur-my-shell \
    gnome-shell-extension-dash-to-dock \
    gnome-shell-extension-hotedge \
    gnome-shell-extension-auto-move-windows

# Compile schemas to ensure they're valid after GNOME shell setup
echo "Compiling schemas after GNOME shell setup..."
glib-compile-schemas /usr/share/glib-2.0/schemas
