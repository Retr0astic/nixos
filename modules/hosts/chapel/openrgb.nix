{...}: {
  config.retr0astic.features.chapel-openrgb = {
    system = {pkgs, ...}: {
      services.udev.packages = [pkgs.openrgb-with-all-plugins];
      hardware.i2c.enable = true;
      boot.kernelModules = [
        "i2c-dev"
        "i2c-piix4"
      ];
    };
    home = {pkgs, ...}: {
      systemd.user.services.openrgb = {
        Unit = {Description = "OpenRGB tray"; After = ["xdg-desktop-portal.service"];};
        Service = {ExecStartPre = "${pkgs.coreutils}/bin/sleep 5"; ExecStart = "${pkgs.openrgb-with-all-plugins}/bin/openrgb --startminimized --rescan"; Restart = "on-failure"; RestartSec = 5;};
        Install = {WantedBy = ["graphical-session.target"];};
      };
    };
  };
}
