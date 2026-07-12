{inputs, ...}: {
  config.retr0astic.features.zen = {
    imports = [({lib, pkgs, ...}: import ./_modules/zen-module.nix {inherit lib pkgs; zenBrowser = inputs.zenBrowser;})];
  };
}
