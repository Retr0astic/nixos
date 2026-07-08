{
  lib,
  pkgs,
  ...
}: let
  inherit (lib.generators) mkLuaInline;

  luaBind = key: dispatcher: {
    _args = [
      (mkLuaInline key)
      (mkLuaInline dispatcher)
    ];
  };

  luaBindWith = key: dispatcher: options: {
    _args = [
      (mkLuaInline key)
      (mkLuaInline dispatcher)
      options
    ];
  };

  key = suffix: ''mainMod .. " + ${suffix}"'';
  exec = command: ''hl.dsp.exec_cmd(${command})'';
in {
  home.packages = with pkgs; [
    hyprshot
    cliphist
    wlsunset
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    configType = "lua";
    systemd.enable = false;
    settings = {
      ipc._var = "noctalia msg";
      mainMod._var = "SUPER";
      terminal._var = "kitty";
      fileManager._var = "dolphin";
      menu._var = mkLuaInline ''ipc .. " panel-toggle launcher"'';

      monitor = {
        output = "desc:Samsung Electric Company LS49AG95 HNTTA00029";
        mode = "5120x1440@239.76";
        position = "0x0";
        scale = 1;
        cm = "auto";
        bitdepth = 10;
        supports_wide_color = 1;
        supports_hdr = 1;
        sdr_max_luminance = 250;
        min_luminance = 0.001;
        max_luminance = 1015;
        max_avg_luminance = 604;
        sdrsaturation = 1.0;
        sdrbrightness = 1.0;
      };

      on = {
        _args = [
          "hyprland.start"
          (mkLuaInline ''
            function()
              hl.exec_cmd("noctalia")
              hl.exec_cmd("systemctl --user start openrgb.service")
              hl.exec_cmd("spotify")
              hl.exec_cmd("vesktop")
            end
          '')
        ];
      };

      env = [
        {_args = ["XCURSOR_SIZE" "24"];}
        {_args = ["HYPRCURSOR_SIZE" "24"];}
        {_args = ["GBM_BACKEND" "nvidia-drm"];}
        {_args = ["__GLX_VENDOR_LIBRARY_NAME" "nvidia"];}
        {_args = ["LIBVA_DRIVER_NAME" "nvidia"];}
        {_args = ["NVD_BACKEND" "direct"];}
        {_args = ["NIXOS_OZONE_WL" "1"];}
        {_args = ["__GL_GSYNC_ALLOWED" "1"];}
        {_args = ["__GL_VRR_ALLOWED" "0"];}
      ];

      config = {
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

        animations.enabled = true;

        dwindle.preserve_split = true;

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
          cm_auto_hdr = 2;
          direct_scanout = 1;
          send_content_type = true;
        };

        input = {
          kb_layout = "us";
          follow_mouse = 1;
          sensitivity = 0;
          touchpad.natural_scroll = false;
        };

        cursor.no_hardware_cursors = 0;
      };

      curve = [
        {_args = ["linear" {type = "bezier"; points = [[0 0] [1 1]];}];}
        {_args = ["md3_standard" {type = "bezier"; points = [[0.2 0] [0 1]];}];}
        {_args = ["md3_decel" {type = "bezier"; points = [[0.05 0.7] [0.1 1]];}];}
        {_args = ["md3_accel" {type = "bezier"; points = [[0.3 0] [0.8 0.15]];}];}
        {_args = ["overshot" {type = "bezier"; points = [[0.05 0.9] [0.1 1.1]];}];}
        {_args = ["crazyshot" {type = "bezier"; points = [[0.1 1.5] [0.76 0.92]];}];}
        {_args = ["hyprnostretch" {type = "bezier"; points = [[0.05 0.9] [0.1 1.0]];}];}
        {_args = ["menu_decel" {type = "bezier"; points = [[0.1 1] [0 1]];}];}
        {_args = ["menu_accel" {type = "bezier"; points = [[0.38 0.04] [1 0.07]];}];}
        {_args = ["easeInOutCirc" {type = "bezier"; points = [[0.85 0] [0.15 1]];}];}
        {_args = ["easeOutCirc" {type = "bezier"; points = [[0 0.55] [0.45 1]];}];}
        {_args = ["easeOutExpo" {type = "bezier"; points = [[0.16 1] [0.3 1]];}];}
        {_args = ["softAcDecel" {type = "bezier"; points = [[0.26 0.26] [0.15 1]];}];}
        {_args = ["md2" {type = "bezier"; points = [[0.4 0] [0.2 1]];}];}
      ];

      animation = [
        {leaf = "windows"; enabled = true; speed = 3; bezier = "md3_decel"; style = "popin 60%";}
        {leaf = "windowsIn"; enabled = true; speed = 3; bezier = "md3_decel"; style = "popin 60%";}
        {leaf = "windowsOut"; enabled = true; speed = 3; bezier = "md3_accel"; style = "popin 60%";}
        {leaf = "border"; enabled = true; speed = 10; bezier = "default";}
        {leaf = "fade"; enabled = true; speed = 3; bezier = "md3_decel";}
        {leaf = "layersIn"; enabled = true; speed = 3; bezier = "menu_decel"; style = "slide";}
        {leaf = "layersOut"; enabled = true; speed = 1.6; bezier = "menu_accel";}
        {leaf = "fadeLayersIn"; enabled = true; speed = 2; bezier = "menu_decel";}
        {leaf = "fadeLayersOut"; enabled = true; speed = 4.5; bezier = "menu_accel";}
        {leaf = "workspaces"; enabled = true; speed = 7; bezier = "menu_decel"; style = "slidevert";}
        {leaf = "specialWorkspace"; enabled = true; speed = 3; bezier = "md3_decel"; style = "slidefadevert, 20%";}
      ];

      gesture = {
        fingers = 3;
        direction = "horizontal";
        action = "workspace";
      };

      device = {
        name = "epic-mouse-v1";
        sensitivity = -0.5;
      };

      bind =
        [
          (luaBind (key "Return") (exec "terminal"))
          (luaBind (key "C") "hl.dsp.window.close()")
          (luaBind (key "CTRL + Escape") "hl.dsp.exit()")
          (luaBind (key "E") (exec "fileManager"))
          (luaBind (key "V") ''hl.dsp.window.float({ action = "toggle" })'')
          (luaBind (key "R") (exec "menu"))
          (luaBind (key "P") "hl.dsp.window.pseudo()")
          (luaBind (key "Z") (exec ''ipc .. " panel-toggle control-center"''))
          (luaBind (key "comma") (exec ''ipc .. " settings-toggle"''))
          (luaBind (key "SHIFT + C") (exec ''ipc .. " panel-toggle launcher clipboard"''))

          (luaBind (key "left") ''hl.dsp.focus({ direction = "left" })'')
          (luaBind (key "right") ''hl.dsp.focus({ direction = "right" })'')
          (luaBind (key "up") ''hl.dsp.focus({ direction = "up" })'')
          (luaBind (key "down") ''hl.dsp.focus({ direction = "down" })'')

          (luaBind (key "S") ''hl.dsp.workspace.toggle_special("scratch")'')
          (luaBind (key "SHIFT + S") ''hl.dsp.window.move({ workspace = "special:scratch" })'')
          (luaBind (key "A") ''hl.dsp.workspace.toggle_special("chat")'')
          (luaBind (key "SHIFT + A") ''hl.dsp.window.move({ workspace = "special:chat" })'')
          (luaBind (key "M") ''hl.dsp.workspace.toggle_special("media")'')
          (luaBind (key "SHIFT + M") ''hl.dsp.window.move({ workspace = "special:media" })'')

          (luaBind (key "CTRL + A") (exec ''"vesktop"''))
          (luaBind (key "CTRL + M") (exec ''"spotify"''))

          (luaBind (key "mouse_down") ''hl.dsp.focus({ workspace = "e+1" })'')
          (luaBind (key "mouse_up") ''hl.dsp.focus({ workspace = "e-1" })'')

          (luaBind (key "print") (exec ''"hyprshot -m window --clipboard-only"''))
          (luaBind ''"print"'' (exec ''"hyprshot -m output --clipboard-only"''))
          (luaBind ''"shift + print"'' (exec ''"hyprshot -m region --clipboard-only"''))
          (luaBind ''"ctrl + print"'' (exec ''"hyprshot -m window"''))
          (luaBind ''"ctrl + " .. mainMod .. " + print"'' (exec ''"hyprshot -m output"''))
          (luaBind ''"ctrl + shift + print"'' (exec ''"hyprshot -m region"''))

          (luaBindWith (key "mouse:272") "hl.dsp.window.drag()" {mouse = true;})
          (luaBindWith (key "mouse:273") "hl.dsp.window.resize()" {mouse = true;})

          (luaBindWith ''"XF86AudioRaiseVolume"'' (exec ''"wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"'') {locked = true; repeating = true;})
          (luaBindWith ''"XF86AudioLowerVolume"'' (exec ''"wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"'') {locked = true; repeating = true;})
          (luaBindWith ''"XF86AudioMute"'' (exec ''"wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"'') {locked = true; repeating = true;})
          (luaBindWith ''"XF86AudioMicMute"'' (exec ''"wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"'') {locked = true; repeating = true;})
          (luaBindWith ''"XF86MonBrightnessUp"'' (exec ''"brightnessctl -e4 -n2 set 5%+"'') {locked = true; repeating = true;})
          (luaBindWith ''"XF86MonBrightnessDown"'' (exec ''"brightnessctl -e4 -n2 set 5%-"'') {locked = true; repeating = true;})

          (luaBindWith ''"XF86AudioNext"'' (exec ''"playerctl next"'') {locked = true;})
          (luaBindWith ''"XF86AudioPause"'' (exec ''"playerctl play-pause"'') {locked = true;})
          (luaBindWith ''"XF86AudioPlay"'' (exec ''"playerctl play-pause"'') {locked = true;})
          (luaBindWith ''"XF86AudioPrev"'' (exec ''"playerctl previous"'') {locked = true;})
        ]
        ++ (lib.concatLists (lib.genList (
            i: let
              workspace = toString (i + 1);
              keyNum =
                if i == 9
                then "0"
                else toString (i + 1);
            in [
              (luaBind (key keyNum) ''hl.dsp.focus({ workspace = "${workspace}" })'')
              (luaBind (key "SHIFT + ${keyNum}") ''hl.dsp.window.move({ workspace = "${workspace}" })'')
            ]
          )
          10));

      window_rule = [
        {match.class = "cs2"; immediate = true;}
        {match.xdg_tag = "proton-game"; content = "game";}
        {match.class = "cs2"; content = "game";}
        {match.class = "(vesktop|Vesktop)"; workspace = "special:chat silent";}
        {match.class = "(Spotify|spotify)"; workspace = "special:media silent";}
        {match.class = "(Spotify|spotify)"; idle_inhibit = "focus";}
        {match.class = "mpv"; idle_inhibit = "focus";}
        {match.modal = true; float = true;}
        {match.class = "xdg-desktop-portal-gtk"; float = true;}
        {match.class = "imv"; float = true;}
        {match.fullscreen = true; match.content = "game"; tonemap = "off";}
        {match.fullscreen = true; match.content = "game"; tonemap = "off"; workspace = "9";}
      ];

      layer_rule = {
        match.namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd)$";
        ignore_alpha = 0.5;
        blur = true;
        blur_popups = true;
      };
    };
  };
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        ignore_systemd_inhibit = false;
        ignore_wayland_inhibit = false;
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
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
  };
}
