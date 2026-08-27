{config, ...}: {
  flake.modules.nixos.sree = osArgs @ {
    lib,
    pkgs,
    ...
  }: {
    # This user owns the home-manager configuration of the same name.
    # Keep the braces. `home-manager.users.sree.imports = [...]` reads as an
    # option path and fails with "expected a module, found a configuration".
    home-manager.users.sree = {
      imports = [config.flake.modules.homeManager.sree];
    };

    programs.fish.enable = true;
    nix.settings.trusted-users = lib.mkAfter ["sree"];

    users.users.sree = {
      isNormalUser = true;
      description = "Sree";
      hashedPasswordFile = osArgs.config.sops.secrets."passwd/sree".path;
      extraGroups = [
        "wheel"
        "video"
        "input"
        "networkmanager"
        "libvirtd"
        "render"
      ];
      shell = pkgs.fish;
      home = "/home/sree";
    };

    # Only applies to `nixos-rebuild build-vm`, never the real system: the
    # sops-encrypted passwd secret can't decrypt with the VM's ephemeral
    # SSH host key, so give the VM a throwaway plaintext password instead.
    virtualisation.vmVariant.users.users.sree = {
      hashedPasswordFile = lib.mkForce null;
      password = "test";
    };
  };

  flake.modules.homeManager.sree = {...}: {
    home = {
      username = "sree";
      homeDirectory = "/home/sree";
      stateVersion = "26.05";
    };
  };
}
