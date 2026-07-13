{config, ...}: { config.retr0astic.themes.noctalia.home = {
  config,
  lib,
  ...
}: {
  home.file.".config/noctalia" = {
    source = builtins.path {
      path = ../noctalia;
      name = "noctalia-assets";
      recursive = true;
    };
    recursive = true;
  };

  programs.kitty.extraConfig = lib.mkMerge [
    ''
      include themes/noctalia.conf
    ''
  ];
}
; }
