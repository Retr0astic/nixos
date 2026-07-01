{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.nvf =
      (inputs.nvf.lib.neovimConfiguration {
        inherit pkgs;
        modules = [../modules/nvf.nix];
      })
      .neovim;
  };
}
