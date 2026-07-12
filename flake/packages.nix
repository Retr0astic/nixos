{config, inputs, ...}: {
  config.retr0astic.nvf = pkgs: (inputs.nvf.lib.neovimConfiguration {
    inherit pkgs;
    modules = [../modules/nvf.nix];
  }).neovim;

  config.perSystem = {pkgs, ...}: {
    packages.nvf = config.retr0astic.nvf pkgs;
  };
}
