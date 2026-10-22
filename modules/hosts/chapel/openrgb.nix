{config, ...}: let
  inherit (config.flake.lib.hypr) luaBind key exec;
in {
  flake.modules.nixos.chapel = {pkgs, ...}: {
    services.udev.packages = [pkgs.openrgb-with-all-plugins];
    hardware.i2c.enable = true;
    users.users.sree.extraGroups = ["i2c"];
    boot.kernelModules = [
      "i2c-dev"
      "i2c-piix4"
    ];
  };

  flake.modules.homeManager.chapel = {
    lib,
    pkgs,
    ...
  }: let
    openrgb = "${pkgs.openrgb-with-all-plugins}/bin/openrgb";
  in {
    # The RAM keeps one LED lit after a single load, so the Off binding loads twice.
    # The SDK server lets `openrgb --profile` reach the running tray instance.
    wayland.windowManager.hyprland.settings.bind = lib.mkAfter [
      (luaBind (key "D") (exec ''"${openrgb} --profile Default"''))
      (luaBind (key "SHIFT + D") (exec ''"${openrgb} --profile Off; sleep 1; ${openrgb} --profile Off"''))
    ];

    systemd.user.services.openrgb = {
      Unit = {
        Description = "OpenRGB tray";
        After = ["graphical-session.target" "xdg-desktop-portal.service"];
      };
      Service = {
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 15";
        ExecStart = "${openrgb} --server --startminimized";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install = {WantedBy = ["default.target"];};
    };
  };
}
