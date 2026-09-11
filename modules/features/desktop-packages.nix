{config, ...}: {
  # Graphical applications only. Anything usable over SSH belongs in a shared
  # aspect (`shell`, `ai-tools`, `hardware-tools`) so bigrig gets it too.
  flake.modules.nixos.desktop-packages = {
    home-manager.sharedModules = [config.flake.modules.homeManager.desktop-packages];
  };

  flake.modules.homeManager.desktop-packages = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = with pkgs;
      [
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
      ]
      ++ (with gst_all_1; [gst-plugins-base gst-plugins-good gst-plugins-bad]);

    # Nautilus already links gst-plugins-good/bad via its own wrapper
    # (modules/features/file-managers.nix). This session variable is
    # additive with --prefix, so it does not change that. It exists for
    # unwrapped GUI apps (e.g. lookapp) that look up plugins at runtime
    # instead of at link time.
    home.sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 =
      lib.makeSearchPath "lib/gstreamer-1.0"
      (with pkgs.gst_all_1; [gst-plugins-base gst-plugins-good gst-plugins-bad]);
  };
}
