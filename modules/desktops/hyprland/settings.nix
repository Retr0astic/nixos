{config, ...}: { config.retr0astic.desktops.hyprland.home = {pkgs, ...}: {
  home.packages = with pkgs; [
    hyprshot
    cliphist
    wlsunset
  ];

  wayland.windowManager.hyprland.settings = {
    mainMod._var = "SUPER";
    terminal._var = "kitty";
    fileManager._var = "dolphin";

    env = [
      {_args = ["XCURSOR_SIZE" "24"];}
      {_args = ["HYPRCURSOR_SIZE" "24"];}
      {_args = ["NIXOS_OZONE_WL" "1"];}
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

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad.natural_scroll = false;
      };

      cursor.no_hardware_cursors = 0;
    };

    device = {
      name = "epic-mouse-v1";
      sensitivity = -0.5;
    };
  };
}
; }
