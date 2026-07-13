{config, ...}: { config.retr0astic.features.services-home.home = {pkgs, ...}: {
  systemd.user.services.openrgb = {
    Unit = {
      Description = "OpenRGB tray";
      After = ["xdg-desktop-portal.service"];
    };
    Service = {
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      ExecStart = "${pkgs.openrgb-with-all-plugins}/bin/openrgb --startminimized";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
; }
