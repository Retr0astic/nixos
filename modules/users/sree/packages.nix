{...}: {
  # Desktop apps only. Guarded on hostname so bigrig (headless) does not pull
  # these in through the shared `sree` module.
  flake.modules.homeManager.sree = {
    lib,
    pkgs,
    osConfig,
    ...
  }: {
    home.packages = lib.mkIf (osConfig.networking.hostName != "bigrig") (with pkgs; [
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
    ]);
  };
}
