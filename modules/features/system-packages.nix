{...}: {
  flake.modules.nixos.system-packages = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      vim
      bat
      wget
      sbctl
      git
      glib
      lm_sensors
      gsettings-desktop-schemas
      opencode
      dconf
      ddcutil
      seahorse
      gnome-keyring
      libsecret
      nwg-look
      adw-gtk3
      qt6Packages.qt6ct
      mpv
      loupe
      swayimg
      kdePackages.dolphin
      kdePackages.ark
      kdePackages.kio-extras
      nautilus
      btop
      p7zip
      python3
      bubblewrap
      unrar
      smartmontools
      claude-code
      gcc
    ];
  };
}
