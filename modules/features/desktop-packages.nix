{config, ...}: {
  # Graphical applications only. Anything usable over SSH belongs in a shared
  # aspect (`shell`, `ai-tools`, `hardware-tools`) so bigrig gets it too.
  flake.modules.nixos.desktop-packages = {
    home-manager.sharedModules = [config.flake.modules.homeManager.desktop-packages];
  };

  flake.modules.homeManager.desktop-packages = {pkgs, ...}: {
    home.packages = with pkgs; [
      # Communication
      vesktop

      # Files and sync
      bitwarden-desktop
      nextcloud-client
      kdePackages.qtwebsockets
      qbittorrent

      # Office and documents
      libreoffice
      hunspell
      hunspellDicts.en-us-large
      obsidian

      # Development
      vscode

      # Browsers and desktop apps
      chromium
      easyeffects
      feishin
      # GUI front end for services.gnome.gnome-keyring.
      seahorse
    ];
  };
}
