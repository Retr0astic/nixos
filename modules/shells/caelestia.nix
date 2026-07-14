{config, inputs, ...}: {
  config.retr0astic.shells.caelestia.home = {
    imports = [inputs.caelestia-shell.homeManagerModules.default];
    programs.caelestia = {
      enable = true;
      cli.enable = true;
      systemd.enable = false;
    };
  };
}
