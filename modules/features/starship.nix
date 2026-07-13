{...}: { config.retr0astic.features.starship.home = {...}: let
  template = builtins.readFile ./starship.toml;
in {
  programs.starship = {
    enable = true;
  };

  home.file.".config/starship/base.toml".text = template;

}
; }
