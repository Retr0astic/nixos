{config, ...}: {
  # Pull the home-manager side in whenever this module is selected.
  flake.modules.nixos.shell = {
    home-manager.sharedModules = [config.flake.modules.homeManager.shell];
  };

  flake.modules.homeManager.shell = {pkgs, ...}: {
    # Tools with no home-manager module of their own. Anything that HAS a
    # module goes in `programs` below instead -- do not list it twice.
    # Shared, so bigrig gets these over SSH as well.
    home.packages = with pkgs; [
      fd
      jq
      btop
      fastfetch
      gh
    ];

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
