{config, ...}: {
  # Pull the home-manager side in whenever this module is selected.
  flake.modules.nixos.programs = {
    home-manager.sharedModules = [config.flake.modules.homeManager.programs];
  };

  flake.modules.homeManager.programs = {
    programs.zathura = {
      enable = true;
      options = {
        selection-clipboard = "clipboard";
        adjust-open = "width";
        recolor = true;
      };
    };
  };
}
