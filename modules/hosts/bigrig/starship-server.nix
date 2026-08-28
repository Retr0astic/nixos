{config, ...}: {
  # bigrig-only starship style: no noctalia palette dependency, unlike
  # modules/features/starship.nix which chapel uses.
  flake.modules.nixos.starship-server = {
    home-manager.sharedModules = [config.flake.modules.homeManager.starship-server];
  };

  flake.modules.homeManager.starship-server = {...}: {
    programs.starship = {
      enable = true;
      settings = builtins.fromTOML (builtins.readFile ./starship-server.toml);
    };
  };
}
