{config, ...}: { config.retr0astic.desktops.hyprland.home = {lib, pkgs, ...}: let
  inherit (lib.generators) mkLuaInline;
in {
  home.packages = with pkgs; [
    hyprshot
    cliphist
    wlsunset
  ];

  wayland.windowManager.hyprland.settings = {
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

    device = {
      name = "epic-mouse-v1";
      sensitivity = -0.5;
    };
  };
}
; }
