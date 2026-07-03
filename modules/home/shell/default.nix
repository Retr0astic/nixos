_: {
  programs = {
    bash = {
      enable = true;
      shellAliases = {
        rebuild = "sudo nixos-rebuild switch --flake ~/nixos";
        update = "cd ~/nixos && nix flake update && sudo nixos-rebuild switch --flake .";
        cd = "z";
        noctalia-config = "noctalia config export > ~/nixos/modules/noctalia/config.toml";
        cat = "bat";
      };
    };

    zoxide.enable = true;

    fzf = {
      enable = true;
      enableBashIntegration = true;
    };

    yazi = {
      enable = true;
      enableBashIntegration = true;
    };
  };
}
