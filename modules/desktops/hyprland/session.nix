{config, ...}: {
  flake.modules.homeManager.hyprland = {lib, ...}: let
    inherit (lib.generators) mkLuaInline;
  in {
    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      portalPackage = null;
      configType = "lua";
      systemd.enable = false;
    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "noctalia msg session lock";
          before_sleep_cmd = "noctalia msg session lock";
          after_sleep_cmd = ''hyprctl dispatch 'hl.dsp.dpms({ action = "enable" })' '';
          ignore_dbus_inhibit = false;
          ignore_systemd_inhibit = false;
          ignore_wayland_inhibit = false;
        };

        listener = [
          {
            timeout = 600;
            on-timeout = "noctalia msg session lock";
          }
          {
            timeout = 900;
            on-timeout = "noctalia msg session lock-and-suspend";
          }
        ];
      };
    };

    systemd.user.sessionVariables = {
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
    };
  };
}
