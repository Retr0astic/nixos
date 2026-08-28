{config, ...}: {
  # Pull the home-manager side in whenever this module is selected.
  flake.modules.nixos.shell = {
    home-manager.sharedModules = [config.flake.modules.homeManager.shell];
  };

  flake.modules.homeManager.shell = _: {
    programs = {
      fish = {
        enable = true;
        shellAliases = {
          cd = "z";
          cat = "bat";
          grep = "rg";
          ls = "eza";
          ll = "eza -lh --git";
          la = "eza -lah --git";
          tree = "eza --tree";
        };
      };
      eza.enable = true;
      bat.enable = true;
      ripgrep.enable = true;
      zoxide = {
        enable = true;
        enableFishIntegration = true;
      };
      fzf = {
        enable = true;
        enableFishIntegration = true;
      };
      yazi = {
        enable = true;
        enableFishIntegration = true;
      };
    };
  };
}
