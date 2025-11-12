#!/bin/bash
set -e

# Enable COPR repo
dnf5 -y copr enable solopasha/hyprland

# --- Base Hyprland setup ---
dnf5 -y install \
  hyprland \
  hyprpaper \
  hyprlock \
  hypridle \
  waybar \
  kitty \
  xdg-desktop-portal-hyprland \
  uwsm

# --- Core utilities ---
dnf5 -y install \
  fzf \
  polkit \
  xfce-polkit \
  dbus-tools \
  dbus-daemon \
  wl-clipboard \
  pavucontrol \
  playerctl \
  qt5-qtwayland \
  qt6-qtwayland \
  gnome-disk-utility \
  openssl \
  vim \
  just \
  alsa-firmware

# --- Sound ---
dnf5 -y install \
  wireplumber \
  pipewire \
  pamixer \
  pulseaudio-utils

# --- Networking ---
dnf5 -y install \
  network-manager-applet \
  NetworkManager-openvpn \
  NetworkManager-openvpn-gnome \
  NetworkManager-openconnect \
  NetworkManager-openconnect-gnome \
  bluez \
  bluez-tools \
  blueman \
  firewall-config

# --- File management ---
dnf5 -y install \
  thunar \
  thunar-archive-plugin \
  thunar-volman \
  xarchiver \
  imv \
  p7zip \
  gvfs-mtp \
  gvfs-gphoto2 \
  gvfs-smb \
  gvfs-nfs \
  gvfs-fuse \
  gvfs-archive \
  android-tools

# --- Screenshot tools ---
dnf5 -y install \
  slurp \
  grim

# --- Display management ---
dnf5 -y install \
  wlr-randr \
  wlsunset \
  brightnessctl \
  kanshi

# --- Notifications ---
dnf5 -y install \
  dunst

