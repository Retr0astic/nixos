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

    # Idle/lock/suspend is handled by noctalia's own [idle] config
    # (modules/noctalia/config.toml) via ext_idle_notifier_v1, including
    # native monitor-power restore on wake. hypridle would duplicate that
    # at the same timeouts, so it stays disabled here.
    services.hypridle.enable = false;

    systemd.user.sessionVariables = {
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
    };
  };
}
