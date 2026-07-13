{config, ...}: { config.retr0astic.themes.noctalia.home = {
  config,
  lib,
  ...
}: {
  programs.kitty.extraConfig = lib.mkMerge [
    ''
      include themes/noctalia.conf
    ''
  ];
}
; }
