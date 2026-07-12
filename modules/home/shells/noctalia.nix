{...}: {
  programs.noctalia = {
    enable = true;
    systemd.enable = false;
  };
}
