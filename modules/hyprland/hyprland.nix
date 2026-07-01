{
  lib,
  pkgs,
  config,
  ...
}: {
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    configType = "hyprlang";
    systemd.enable = false;
    settings = {
      "$ipc" = "noctalia msg";
      "$mainMod" = "SUPER";
      "$terminal" = "kitty";
      "$fileManager" = "dolphin";
      "$menu" = "$ipc panel-toggle launcher";
      monitor = [
        "DP-2, highresxmaxwidth@highrr,0x0, 1, cm, auto, bitdepth, 10, sdrsaturation, 1, sdrbrightness, 1.0"
      ];

      exec-once = [
        "noctalia"
      ];

      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "LIBVA_DRIVER_NAME,nvidia"
        "NVD_BACKEND,direct"
        "NIXOS_OZONE_WL,1"
        "__GL_GSYNC_ALLOWED,1"
        "__GL_VRR_ALLOWED,0"
      ];

      general = {
        gaps_in = 3;
        gaps_out = 5;
        border_size = 1;
        resize_on_border = false;
        allow_tearing = true;
        layout = "master";
      };

      decoration = {
        rounding = 5;
        rounding_power = 2;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        dim_special = 0.4;
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
          special = true;
        };
      };

      animations = {
        enabled = true;

        bezier = [
          "linear, 0, 0, 1, 1"
          "md3_standard, 0.2, 0, 0, 1"
          "md3_decel, 0.05, 0.7, 0.1, 1"
          "md3_accel, 0.3, 0, 0.8, 0.15"
          "overshot, 0.05, 0.9, 0.1, 1.1"
          "crazyshot, 0.1, 1.5, 0.76, 0.92"
          "hyprnostretch, 0.05, 0.9, 0.1, 1.0"
          "menu_decel, 0.1, 1, 0, 1"
          "menu_accel, 0.38, 0.04, 1, 0.07"
          "easeInOutCirc, 0.85, 0, 0.15, 1"
          "easeOutCirc, 0, 0.55, 0.45, 1"
          "easeOutExpo, 0.16, 1, 0.3, 1"
          "softAcDecel, 0.26, 0.26, 0.15, 1"
          "md2, 0.4, 0, 0.2, 1"
        ];

        animation = [
          "windows, 1, 3, md3_decel, popin 60%"
          "windowsIn, 1, 3, md3_decel, popin 60%"
          "windowsOut, 1, 3, md3_accel, popin 60%"
          "border, 1, 10, default"
          "fade, 1, 3, md3_decel"
          "layersIn, 1, 3, menu_decel, slide"
          "layersOut, 1, 1.6, menu_accel"
          "fadeLayersIn, 1, 2, menu_decel"
          "fadeLayersOut, 1, 4.5, menu_accel"
          "workspaces, 1, 7, menu_decel, slidevert"
          "specialWorkspace, 1, 3, md3_decel, slidefadevert, 20%"
        ];
      };

      dwindle = {
        preserve_split = true;
      };

      master = {
        new_status = "inherit";
        orientation = "center";
        slave_count_for_center_master = 0;
      };

      misc = {
        force_default_wallpaper = -1;
        disable_hyprland_logo = false;
        vrr = 2;
      };

      render = {
        cm_enabled = true;
        cm_auto_hdr = true;
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
        "$mainMod, Return, exec, $terminal"
        "$mainMod, C, killactive"
        "$mainMod CTRL, Escape, exit"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, V, togglefloating"
        "$mainMod, R, exec, $menu"
        "$mainMod, P, pseudo"
        "$mainMod, Z, exec, $ipc panel-toggle control-center"
        "$mainMod, comma, exec, $ipc settings-toggle"
        "$mainMod SHIFT, c, exec, $ipc panel-toggle launcher clipboard"

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

        "$mainMod, print,       exec, hyprshot -m window --clipboard-only"
        ", print,               exec, hyprshot -m output --clipboard-only"
        "shift, print,          exec, hyprshot -m region --clipboard-only"
        "ctrl, print,           exec, hyprshot -m window"
        "ctrl $mainMod, print,  exec, hyprshot -m output"
        "ctrl shift, print,     exec, hyprshot -m region"
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

      windowrule = [
        "match:class = cs2,immediate = yes"
        "match:class xdg-desktop-portal-gtk, float on"
        "match:class imv, float on"
      ];
      cursor = ["no_hardware_cursors = 2"];

      layerrule = {
        name = "noctalia";
        "match:namespace" = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd)$";
        ignore_alpha = 0.5;
        blur = true;
        blur_popups = true;
      };
    };
  };
  xdg.configFile."hypr/hyprland.lua".source = ./hyprland.lua;

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 600;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 900;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
  systemd.user.sessionVariables = {
    WAYLAND_DISPLAY = "$WAYLAND_DISPLAY";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
  };
}
