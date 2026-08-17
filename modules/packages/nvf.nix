{inputs, ...}: let
  mkNvf = pkgs:
    (inputs.nvf.lib.neovimConfiguration {
      inherit pkgs;
      modules = [./_nvf/package.nix];
    })
    .neovim;
in {
  flake.modules.nixos.nvf = {pkgs, ...}: {
    environment.systemPackages = [(mkNvf pkgs)];
  };

  perSystem = {pkgs, ...}: {
    packages.nvf = mkNvf pkgs;
  };
}
