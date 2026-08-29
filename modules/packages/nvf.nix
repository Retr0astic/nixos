{
  config,
  inputs,
  ...
}: let
  mkNvf = pkgs:
    (inputs.nvf.lib.neovimConfiguration {
      inherit pkgs;
      modules = [./_nvf/package.nix];
    })
    .neovim;
in {
  # Pull the home-manager side in whenever this module is selected.
  flake.modules.nixos.nvf = {
    home-manager.sharedModules = [config.flake.modules.homeManager.nvf];
  };

  flake.modules.homeManager.nvf = {pkgs, ...}: {
    # This is the user's editor. `vim` in `core` covers root and recovery,
    # so nvf does not belong in systemPackages. It sets viAlias and vimAlias,
    # and the home profile comes first on PATH, so `vim` opens nvf for sree
    # and plain vim for root.
    home.packages = [(mkNvf pkgs)];
  };

  perSystem = {pkgs, ...}: {
    packages.nvf = mkNvf pkgs;
  };
}
