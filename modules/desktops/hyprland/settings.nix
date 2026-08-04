{config, ...}: {
  config.retr0astic.desktops.hyprland.home = {pkgs, ...}: {
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
          gaps_in = 4;
          gaps_out = 8;
          border_size = 2;
          "col.active_border" = {
            colors = ["rgba(ffade1ee)" "rgba(ffb5a1ee)"];
            angle = 45;
          };
          "col.inactive_border" = "rgba(5d4038ee)";
          resize_on_border = false;
          allow_tearing = true;
          layout = "master";
        };

        decoration = {
          rounding = 5;
          rounding_power = 2;
          active_opacity = 1.0;
          inactive_opacity = 1.0;
          dim_special = 0.6;
          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
            color = "rgba(1a1a1aee)";
          };
          blur = {
            enabled = true;
            xray = true;
            special = false;
            new_optimizations = true;
            size = 10;
            passes = 3;
            brightness = 1;
            noise = 0.05;
            contrast = 0.89;
            vibrancy = 0.5;
            vibrancy_darkness = 0.5;
            popups = false;
            popups_ignorealpha = 0.6;
            input_methods = true;
            input_methods_ignorealpha = 0.8;
          };
          dim_inactive = true;
          dim_strength = 0.05;
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
          allow_session_lock_restore = true;
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
  };
}
