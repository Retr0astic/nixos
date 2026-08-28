{config, ...}: {
  # Desktop apps, opt-in like `programs`/`terminals`/`xdg`: only a host that
  # names `desktop-packages` in its base list gets these. bigrig (headless)
  # does not.
  flake.modules.nixos.desktop-packages = {pkgs, ...}: {
    home-manager.sharedModules = [config.flake.modules.homeManager.desktop-packages];

    environment.systemPackages = with pkgs; [
      mpv
      loupe
      swayimg
      kdePackages.dolphin
      kdePackages.ark
      kdePackages.kio-extras
      nautilus
      qt6Packages.qt6ct
      adw-gtk3
      nwg-look
      seahorse
      playerctl
      ddcutil
      sbctl
      dconf
      gsettings-desktop-schemas
    ];
  };

  flake.modules.homeManager.desktop-packages = {pkgs, ...}: {
    home.packages = with pkgs; [
      # Communication
      vesktop
      bitwarden-desktop

      # Files and sync
      nextcloud-client
      kdePackages.qtwebsockets
      qbittorrent

      # Office and documents
      libreoffice
      hunspell
      hunspellDicts.en-us-large

      # Dev and AI tools
      codex
      mcp-nixos
      vscode

      # Browsers and desktop apps
      chromium
      obsidian
      easyeffects
      feishin
    ];
  };
}
