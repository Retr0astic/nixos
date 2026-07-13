{...}: {
  config.retr0astic.features.chapel-openrgb = {
    system = {pkgs, ...}: {
      services.hardware.openrgb = {enable = true; motherboard = "amd"; package = pkgs.openrgb-with-all-plugins;};
      hardware.i2c.enable = true;
      systemd.services.openrgb.enable = false;
    };
    home = {pkgs, lib, ...}: {
      systemd.user.services.openrgb = {
        Unit = {Description = "OpenRGB tray"; After = ["xdg-desktop-portal.service"];};
        Service = {ExecStartPre = "${pkgs.coreutils}/bin/sleep 5"; ExecStart = "${pkgs.openrgb-with-all-plugins}/bin/openrgb --startminimized"; Restart = "on-failure"; RestartSec = 5;};
      };
      wayland.windowManager.hyprland.settings.on = lib.mkAfter [{_args = ["hyprland.start" (lib.generators.mkLuaInline ''function() hl.exec_cmd("systemctl --user start openrgb.service") end'')];}];
    };
  };
}
