#!/bin/bash


dnf5 -y install gnome-tweaks 
dnf install -y gnome-extensions-app 
dnf install -y gnome-shell-extension-appindicator \
    gnome-shell-extension-blur-my-shell \
    gnome-shell-extension-dash-to-dock \
    gnome-shell-extension-hotedge \

# Compile schemas to ensure they're valid after GNOME shell setup
echo "Compiling schemas after GNOME shell setup..."
glib-compile-schemas /usr/share/glib-2.0/schemas
