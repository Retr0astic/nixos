{config, ...}: {
  # bigrig-only starship style: no noctalia palette dependency, unlike
  # modules/hosts/chapel/starship.nix which chapel uses.
  flake.modules.nixos.starship-bigrig = {
    home-manager.sharedModules = [config.flake.modules.homeManager.starship-bigrig];
  };

  flake.modules.homeManager.starship-bigrig = {...}: {
    programs.starship = {
      enable = true;
      settings = builtins.fromTOML (builtins.readFile ./starship-bigrig.toml);
    };
  };
}
