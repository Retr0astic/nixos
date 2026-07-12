{noctalia, ...}: {
  imports = [noctalia.homeModules.default];

  programs.noctalia = {
    enable = true;
    systemd.enable = false;
  };
}
