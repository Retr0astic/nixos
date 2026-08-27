{...}: {
  flake.modules.homeManager.sree = {pkgs, ...}: {
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
