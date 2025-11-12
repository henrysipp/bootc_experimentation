#!/bin/bash

dnf5  -y copr enable solopasha/hyprland
dnf5 -y install hyprland hyprpaper hyprlock hypridle waybar kitty xdg-desktop-portal-hyprland
# dnf5 -y install hyprland-devel # If you want to build plugins (use hyprpm)com/