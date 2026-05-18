{ config, pkgs, inputs, system, ... }: {

  imports = [
    inputs.noctalia.homeModules.default
    inputs.silentSDDM.nixosModules.default
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

  programs.silentSDDM = {
    enable = true;
    theme = "defaul";
    #settings = { ... }; see example in module
    };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "default";  # Noctalia will toggle this to prefer-dark/prefer-light
      gtk-theme = "adw-gtk3";
      cursor-theme = "Adwaita";
      cursor-size = 24;
    };
  };

  xdg.configFile = let
    src = "${inputs.lucidglyph}/src/modules";
 	 in {
	    "fontconfig/conf.d/11-lucidglyph-grayscale.conf".source = 
	      "${src}/fontconfig/11-lucidglyph-grayscale.conf";
	    "fontconfig/conf.d/12-lucidglyph-hinting.conf".source = 
	      "${src}/fontconfig/12-lucidglyph-hinting.conf";
	    "fontconfig/conf.d/13-lucidglyph-embolden.conf".source = 
	      "${src}/fontconfig/13-lucidglyph-embolden.conf";
	    "environment.d/lucidglyph.conf".source = 
	      "${src}/environment/lucidglyph-freetype-properties.conf";
            };
  systemd.user.sessionVariables = {
    WAYLAND_DISPLAY = "$WAYLAND_DISPLAY";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
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

wayland.windowManager.hyprland = {
  enable = true;
  systemd.enable = true;
  settings = {
    "$ipc" = "noctalia-shell ipc call";
    "$mainMod" = "SUPER";
    "$terminal" = "kitty";
    "$fileManager" = "dolphin";
    "$menu" = "$ipc launcher toggle";

    monitor = "DP-5, highresxmaxwidth@highrr, 0x0, 1, bitdepth, 10, cm, auto";

    exec-once = [ 
     # Execute these at launch to sync the environment
      "noctalia-shell"
    ];

    env = [
      "XCURSOR_SIZE,24"
      "HYPRCURSOR_SIZE,24"
      "XCURSOR_SIZE,24"
      "HYPRCURSOR_SIZE,24"
      "GBM_BACKEND,nvidia-drm"
      "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      "LIBVA_DRIVER_NAME,nvidia"
      "__GL_GSYNC_ALLOWED,0"
      "__GL_VRR_ALLOWED,0"
      "NVD_BACKEND,direct"
      "DXVK_HDR,1"
      "NIXOS_OZONE_WL,1"
    ];

    general = {
      gaps_in = 5;
      gaps_out = 10;
      border_size = 2;
      "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
      "col.inactive_border" = "rgba(595959aa)";
      resize_on_border = false;
      allow_tearing = false;
      layout = "dwindle";
    };

    decoration = {
      rounding = 20;
      rounding_power = 2;
      active_opacity = 1.0;
      inactive_opacity = 1.0;
      shadow = {
        enabled = true;
        range = 4;
        render_power = 3;
        color = "rgba(1a1a1aee)";
      };
      blur = {
        enabled = true;
        size = 3;
        passes = 2;
        vibrancy = 0.1696;
      };
    };

    animations = {
      enabled = true;
      bezier = [
        "easeOutQuint,   0.23, 1,    0.32, 1"
        "easeInOutCubic, 0.65, 0.05, 0.36, 1"
        "linear,         0,    0,    1,    1"
        "almostLinear,   0.5,  0.5,  0.75, 1"
        "quick,          0.15, 0,    0.1,  1"
      ];
      animation = [
        "global,        1, 10,   default"
        "border,        1, 5.39, easeOutQuint"
        "windows,       1, 4.79, easeOutQuint"
        "windowsIn,     1, 4.1,  easeOutQuint, popin 87%"
        "windowsOut,    1, 1.49, linear,       popin 87%"
        "fadeIn,        1, 1.73, almostLinear"
        "fadeOut,       1, 1.46, almostLinear"
        "fade,          1, 3.03, quick"
        "layers,        1, 3.81, easeOutQuint"
        "layersIn,      1, 4,    easeOutQuint, fade"
        "layersOut,     1, 1.5,  linear,       fade"
        "fadeLayersIn,  1, 1.79, almostLinear"
        "fadeLayersOut, 1, 1.39, almostLinear"
        "workspaces,    1, 1.94, almostLinear, fade"
        "workspacesIn,  1, 1.21, almostLinear, fade"
        "workspacesOut, 1, 1.94, almostLinear, fade"
        "zoomFactor,    1, 7,    quick"
      ];
    };

    dwindle = {
      pseudotile = true;
      preserve_split = true;
    };

    master = {
      new_status = "master";
    };

    misc = {
      force_default_wallpaper = -1;
      disable_hyprland_logo = false;
      vrr = 2;
    };

    render = {
      cm_enabled = true;
      cm_fs_passthrough = 2;
      direct_scanout = true;
    };

    input = {
      kb_layout = "us";
      follow_mouse = 1;
      sensitivity = 0;
      touchpad.natural_scroll = false;
    };

    gesture = "3, horizontal, workspace";

    device = {
      name = "epic-mouse-v1";
      sensitivity = -0.5;
    };

    bind = [
      "$mainMod, Q, exec, $terminal"
      "$mainMod, C, killactive"
      "$mainMod, M, exit"
      "$mainMod, E, exec, $fileManager"
      "$mainMod, V, togglefloating"
      "$mainMod, R, exec, $menu"
      "$mainMod, P, pseudo"
      "$mainMod, J, togglesplit"
      "$mainMod, Z, exec, $ipc controlCenter toggle"
      "$mainMod, comma, exec, $ipc setting toggle"

      "$mainMod, left,  movefocus, l"
      "$mainMod, right, movefocus, r"
      "$mainMod, up,    movefocus, u"
      "$mainMod, down,  movefocus, d"

      "$mainMod, 1, workspace, 1"
      "$mainMod, 2, workspace, 2"
      "$mainMod, 3, workspace, 3"
      "$mainMod, 4, workspace, 4"
      "$mainMod, 5, workspace, 5"
      "$mainMod, 6, workspace, 6"
      "$mainMod, 7, workspace, 7"
      "$mainMod, 8, workspace, 8"
      "$mainMod, 9, workspace, 9"
      "$mainMod, 0, workspace, 10"

      "$mainMod SHIFT, 1, movetoworkspace, 1"
      "$mainMod SHIFT, 2, movetoworkspace, 2"
      "$mainMod SHIFT, 3, movetoworkspace, 3"
      "$mainMod SHIFT, 4, movetoworkspace, 4"
      "$mainMod SHIFT, 5, movetoworkspace, 5"

      "$mainMod SHIFT, 6, movetoworkspace, 6"
      "$mainMod SHIFT, 7, movetoworkspace, 7"
      "$mainMod SHIFT, 8, movetoworkspace, 8"
      "$mainMod SHIFT, 9, movetoworkspace, 9"
      "$mainMod SHIFT, 0, movetoworkspace, 10"

      "$mainMod, S, togglespecialworkspace, magic"
      "$mainMod SHIFT, S, movetoworkspace, special:magic"

      "$mainMod, mouse_down, workspace, e+1"
      "$mainMod, mouse_up,   workspace, e-1"

      "$mainMod, PRINT,       exec, hyprshot -m window"
      ", PRINT,               exec, hyprshot -m output"
      "SHIFT, PRINT,          exec, hyprshot -m region"
    ];

    bindm = [
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
    ];

    bindel = [
      ", XF86AudioRaiseVolume,  exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ", XF86AudioMute,         exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioMicMute,      exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ", XF86MonBrightnessUp,   exec, brightnessctl -e4 -n2 set 5%+"
      ", XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
    ];

    bindl = [
      ", XF86AudioNext,  exec, playerctl next"
      ", XF86AudioPause, exec, playerctl play-pause"
      ", XF86AudioPlay,  exec, playerctl play-pause"
      ", XF86AudioPrev,  exec, playerctl previous"
    ];
  };


  # layerrule block and source line can't be expressed as
  # structured settings so they go here as raw config
    extraConfig = ''
      layerrule {
        name = noctalia
        match:namespace = noctalia-background-.*$
        ignore_alpha = 0.5
        blur = true
        blur_popups = true
      }

    source = /home/sree/.config/hypr/noctalia/noctalia-colors.conf

  '';
};

}
