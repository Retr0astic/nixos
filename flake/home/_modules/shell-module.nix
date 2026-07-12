_: {
  programs = {
    fish = {
      enable = true;
      shellAliases = {
        rebuild = "sudo nixos-rebuild switch --flake ~/nixos";
        update = "cd ~/nixos && nix flake update && sudo nixos-rebuild switch --flake .";
        cd = "z";
        noctalia-config = "noctalia config export > ~/nixos/modules/noctalia/config.toml";
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
}
