{inputs, ...}: {
  config.retr0astic.features.fonts = {
    imports = [({pkgs, ...}: import ./_modules/fonts-module.nix {inherit pkgs; lucidglyph = inputs.lucidglyph;})];
  };
}
