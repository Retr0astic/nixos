{config, ...}: {
  # Desktop apps, opt-in like `programs`/`terminals`/`xdg`: only a host that
  # names `desktop-packages` in its base list gets these. bigrig (headless)
  # does not.
  flake.modules.nixos.desktop-packages = {
    home-manager.sharedModules = [config.flake.modules.homeManager.desktop-packages];
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
      gh

      # CLI utilities
      fastfetch
      fd
      htop
      ripgrep
      eza
      jq

      # Browsers and desktop apps
      chromium
      obsidian
      easyeffects
      feishin
    ];
  };
}
