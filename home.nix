{ config, pkgs, inputs, system, ... }: {

  imports = [
    inputs.noctalia.homeModules.default
    ./hyprland.nix
  ];

  home = {
    username = "sree";
    homeDirectory = "/home/sree";
    stateVersion = "25.11";
    packages = with pkgs; [
      fastfetch
      htop
      kitty
      wezterm
      ghostty
      inputs.zenBrowser.packages."${system}".default
      hyprshot
      vesktop
      jq
      heroic        # Epic/GOG launcher
      gamemode
      gamescope-wsi
      gamescope     # Valve's micro compositor, great for HDR/VRR per-game
      mangohud 
      goofcord
      libsecret
      openrgb
      ludusavi
      gh
      bitwarden-desktop
      zoxide
      cliphist
      wlsunset
      kdePackages.qtwebsockets
    ];
  };

 # Programs
  programs.bash = {
    enable = true;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos";
      update = "cd ~/nixos && nix flake update && sudo nixos-rebuild switch --flake .";
      cd = "z";
    };
  };
  programs.zoxide = {
    enable = true;
   };  

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      gruvbox-material
      nerdtree
    ];
  };
  programs.kitty = {
    enable = true;
    settings = {
	    dynamic_background_opacity = true;
	    background_opacity = "0.5";
	    background_blur = 5;
    };
    font = {
    	name = "JetBrainsMono Nerd Font";
    	size = 11;
    };
    extraConfig = ''
      include ~/.config/kitty/themes/noctalia.conf
    '';
  };
  programs.wezterm.enable = true;
  programs.ghostty.enable = true;
  programs.fzf.enableBashIntegration = true;
  programs.noctalia-shell = {
    enable = true;
    settings = builtins.fromJSON (builtins.readFile ./noctalia/noctalia-settings.json);
  };

  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
  };
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
  };

 # Themeing

 qt = {
  enable = true;
  platformTheme.name = "gtk";  # makes Qt follow GTK font
};

gtk = {
  enable = true;
  font = {
    name = "Inter";
    size = 11;
  };
};

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "default";  # Noctalia will toggle this to prefer-dark/prefer-light
      gtk-theme = "adw-gtk3";
      cursor-theme = "Adwaita";
      cursor-size = 24;
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
    createDirectories = true;  # actually creates them on rebuild
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
