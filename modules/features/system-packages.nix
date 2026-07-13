{...}: {
  config.retr0astic.features.system-packages.system = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [vim bat wget sbctl git glib lm_sensors gsettings-desktop-schemas opencode dconf ddcutil seahorse gnome-keyring libsecret nwg-look adw-gtk3 qt6Packages.qt6ct mpv imv kdePackages.dolphin kdePackages.ark kdePackages.kio-extras btop p7zip bubblewrap unrar];
  };
}
