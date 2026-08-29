{config, ...}: {
  # Pull the home-manager side in whenever this module is selected.
  flake.modules.nixos.starship = {
    home-manager.sharedModules = [config.flake.modules.homeManager.starship];
  };

  flake.modules.homeManager.starship = {...}: let
    template = builtins.readFile ./starship.toml;
  in {
    programs.starship = {
      enable = true;
    };

    home.file.".config/starship/base.toml".text = template;
  };
}
