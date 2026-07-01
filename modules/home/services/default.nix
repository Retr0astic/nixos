{pkgs, ...}: {
  systemd.user.services.openrgb = {
    Unit = {
      Description = "OpenRGB tray";
      After = [
        "graphical-session.target"
        "noctalia.service"
      ];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.openrgb-with-all-plugins}/bin/openrgb --startminimized";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
