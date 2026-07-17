{config, ...}: {
  config.retr0astic.features.nvf.system = {pkgs, ...}: {
    environment.systemPackages = [(config.retr0astic.nvf pkgs)];
  };
}
