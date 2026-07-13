{config, ...}: { config.retr0astic.themes.noctalia.home = {
  config,
  lib,
  ...
}: {
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
; }
