{pkgs, ...}: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [
    "root"
    "sree"
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "pnpm-10.29.2"
    "electron-39.8.10"
  ];

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
    imv
    kdePackages.dolphin
    btop
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    SDL_VIDEODRIVER = "wayland";
    GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";
    SAL_USE_VCLPLUGIN = "qt6";
  };

  programs.dconf.enable = true;
  programs.nix-ld = {
    enable = true;
    libraries = [];
  };
}
