{...}: {
  flake.modules.nixos.chapel = {pkgs, ...}: {
    services.udev.packages = [pkgs.openrgb-with-all-plugins];
    hardware.i2c.enable = true;
    boot.kernelModules = [
      "i2c-dev"
      "i2c-piix4"
    ];
  };

  flake.modules.homeManager.chapel = {pkgs, ...}: {
    systemd.user.services.openrgb = {
      Unit = {
        Description = "OpenRGB tray";
        After = ["graphical-session.target" "xdg-desktop-portal.service"];
      };
      Service = {
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 15";
        ExecStart = "${pkgs.openrgb-with-all-plugins}/bin/openrgb --startminimized";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install = {WantedBy = ["default.target"];};
    };
  };
}
