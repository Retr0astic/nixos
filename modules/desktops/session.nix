{config, ...}: { config.retr0astic.desktops.hyprland.home = {lib, ...}: let
  inherit (lib.generators) mkLuaInline;
in {
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    configType = "lua";
    systemd.enable = false;
    extraConfig = ''
      local hm_xdg_config_home = os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config"
      package.path = hm_xdg_config_home .. "/hypr/?.lua;" .. hm_xdg_config_home .. "/hypr/?/init.lua;" .. package.path
      require("noctalia").apply_theme()
    '';
    settings.on = {
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
; }
