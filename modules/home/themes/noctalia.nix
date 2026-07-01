{
  config,
  inputs,
  lib,
  ...
}: {
  imports = [inputs.noctalia.homeModules.default];

  programs.noctalia = {
    enable = true;
    systemd.enable = true;
  };

  home.file.".config/noctalia" = {
    source = config.lib.file.mkOutOfStoreSymlink "/home/sree/nixos/modules/noctalia";
    recursive = true;
  };

  programs.kitty.extraConfig = lib.mkMerge [
    ''
      include themes/noctalia.conf
    ''
  ];
}
