{pkgs, ...}: {
  systemd.user.services.openrgb = {
    Unit = {
      Description = "OpenRGB";
      After = ["graphical-session-pre.target"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.openrgb-with-all-plugins}/bin/openrgb --startminimized";
      Restart = "on-failure";
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
