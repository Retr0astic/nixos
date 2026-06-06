{
  pkgs,
  lib,
  ...
}: let
  lucidglyph = pkgs.fetchFromGitHub {
    owner = "maximilionus";
    repo = "lucidglyph";
    rev = "v0.14.0";
    hash = "sha256-RAHGVEUS5Hkig8xtPQCcaLVsXY0ER6N4eYNnYiV56eM=";
  };

  lucidglyphConf = pkgs.runCommand "lucidglyph-fontconfig" {} ''
    mkdir -p $out/etc/fonts/conf.d
    ln -s ${lucidglyph}/src/modules/fontconfig/11-lucidglyph-grayscale.conf \
      $out/etc/fonts/conf.d/11-lucidglyph-grayscale.conf
    ln -s ${lucidglyph}/src/modules/fontconfig/12-lucidglyph-slight-hinting.conf \
      $out/etc/fonts/conf.d/12-lucidglyph-slight-hinting.conf
  '';
in {
  fonts.fontconfig = {
    enable = true;
    confPackages = [lucidglyphConf];
  };

  environment.variables = {
    FREETYPE_PROPERTIES = "autofitter:darkening-parameters=499,300,1000,200 autofitter:no-stem-darkening=0";
  };
}
