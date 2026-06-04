#!/usr/bin/env bash
if [ "$1" = "true" ]; then
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
else
    gsettings set org.gnome.desktop.interface color-scheme prefer-light
fi
