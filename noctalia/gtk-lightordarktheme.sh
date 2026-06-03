#!/usr/bin/env bash
# Noctalia passes the current mode as an argument: "dark" or "light"
if [ "$1" = "true" ]; then
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
else
gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
fi
