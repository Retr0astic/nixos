{...}: {
  config.retr0astic.features.shell.home = _: {
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
