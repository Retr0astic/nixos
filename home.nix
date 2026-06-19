{
  config,
  pkgs,
  inputs,
  ...
}: {
  home = {
    username = "sree";
    homeDirectory = "/home/sree";
    stateVersion = "26.05";
    packages = with pkgs; [
      fastfetch
      htop
      kitty
      wezterm
      ghostty
      hyprshot
      vesktop
      jq
      gamescope-wsi
      gamescope # Valve's micro compositor, great for HDR/VRR per-game
      mangohud
      libsecret
      ludusavi
      gh
      bitwarden-desktop
      zoxide
      cliphist
      wlsunset
      nextcloud-client
      kdePackages.qtwebsockets
      protonup-qt
      nextcloud-client
      kdePackages.dolphin
    ];
  };

  imports = [
    ./modules/hyprland/hyprland.nix
    inputs.spicetify-nix.homeManagerModules.default
  ];

  # Programs
  programs.bash = {
    enable = true;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos";
      update = "cd ~/nixos && nix flake update && sudo nixos-rebuild switch --flake .";
      cd = "z";
      noctalia-config = "noctalia config export > ~/nixos/modules/noctalia/config.toml";
    };
  };
  programs.zoxide = {
    enable = true;
  };

  programs.kitty = {
    enable = true;
    settings = {
      dynamic_background_opacity = true;
      background_opacity = "0.75";
      background_blur = 7;
    };
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 10;
    };
  };

  programs.wezterm.enable = true;
  programs.ghostty.enable = true;
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
  };
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.spicetify = let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  in {
    enable = true;

    enabledExtensions = with spicePkgs.extensions; [
      adblock
      hidePodcasts
      shuffle # shuffle+ (special characters are sanitized out of extension names)
    ];
    enabledCustomApps = with spicePkgs.apps; [
      newReleases
      ncsVisualizer
    ];
    enabledSnippets = with spicePkgs.snippets; [
      rotatingCoverart
      pointer
    ];

    theme = spicePkgs.themes.text;
    #    colorScheme = "Kitty";
  };

  # Themeing

  qt = {
    enable = true;
    platformTheme.name = "gtk"; # makes Qt follow GTK font
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  gtk = {
    enable = true;
    font = {
      name = "Inter";
      size = 11;
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
    };
    # Note the different syntax for gtk3 and gtk4
    gtk3.extraConfig = {
      "gtk-cursor-theme-name" = "Bibata-Modern-Classic";
    };
    gtk4.extraConfig = {
      Settings = ''
        gtk-cursor-theme-name=Bibata-Modern-Classic
      '';
    };
  };

  systemd.user.sessionVariables = {
    WAYLAND_DISPLAY = "$WAYLAND_DISPLAY";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    #    QT_QPA_PLATFORMTHEME = "qt6ct";
  };
  xdg.userDirs = {
    enable = true;
    createDirectories = true; # actually creates them on rebuild
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    pictures = "${config.home.homeDirectory}/Pictures";
    music = "${config.home.homeDirectory}/Music";
    videos = "${config.home.homeDirectory}/Videos";
    desktop = "${config.home.homeDirectory}/Desktop";
    templates = "${config.home.homeDirectory}/Templates";
    publicShare = "${config.home.homeDirectory}/Public";
  };
}
