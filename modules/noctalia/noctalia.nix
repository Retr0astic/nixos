{
  inputs,
  lib,
  ...
}: {
  # install package
  #  environment.systemPackages = with pkgs; [
  #  inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  #  # ... maybe other stuff
  #];

  home-manager.users.sree = {config, ...}: {
    imports = [
      inputs.noctalia.homeModules.default
      ../../home.nix
    ];

    programs.noctalia = {
      enable = true;
      systemd.enable = true;
    };

    home.file.".config/noctalia" = {
      source =
        config.lib.file.mkOutOfStoreSymlink
        "/home/sree/nixos/modules/noctalia";
      recursive = true;
    };

    programs.kitty = {
      extraConfig = lib.mkMerge [
        ''
          include themes/noctalia.conf
        ''
      ];
    };
  };
}
