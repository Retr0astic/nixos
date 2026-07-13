{config, inputs, ...}: { config.retr0astic.shells.noctalia.home = {
  imports = [inputs.noctalia.homeModules.default];
  programs.noctalia = {
    enable = true;
    systemd.enable = false;
  };
}; }
