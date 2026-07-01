{pkgs, ...}: {
  home = {
    username = "sree";
    homeDirectory = "/home/sree";
    stateVersion = "26.05";
    packages = with pkgs; [
      fastfetch
      htop
      vesktop
      jq
      gamescope-wsi
      gamescope
      mangohud
      libsecret
      ludusavi
      gh
      bitwarden-desktop
      nextcloud-client
      kdePackages.qtwebsockets
      protonup-qt
      qbittorrent
      libreoffice-qt6-fresh
      hunspell
      hunspellDicts.en-us-large
      codex
    ];
  };
}
