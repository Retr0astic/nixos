{
  pkgs,
  inputs,
  ...
}: let
  lucidglyphConf = pkgs.runCommand "lucidglyph-fontconfig" {} ''
    mkdir -p $out/etc/fonts/conf.d
    ln -s ${inputs.lucidglyph}/src/modules/fontconfig/11-lucidglyph-grayscale.conf \
      $out/etc/fonts/conf.d/11-lucidglyph-grayscale.conf
    ln -s ${inputs.lucidglyph}/src/modules/fontconfig/11-lucidglyph-hinting-slight.conf \
      $out/etc/fonts/conf.d/11-lucidglyph-hinting-slight.conf
  '';
in {
  fonts = {
    packages = with pkgs; [
      inter
      geist-font
      jetbrains-mono
      iosevka
      noto-fonts
      noto-fonts-color-emoji
      nerd-fonts.jetbrains-mono
    ];

    fontconfig = {
      enable = true;
      confPackages = [lucidglyphConf];
    };
  };

  environment.variables = {
    FREETYPE_PROPERTIES = "autofitter:no-stem-darkening=0";
  };
}
