{...}: let
  colors = builtins.fromJSON (builtins.readFile ../noctalia/colors.json);
  template = builtins.readFile ./starship.toml;
  starshipConfig = builtins.replaceStrings
    [
      "@primary@"
      "@secondary@"
      "@tertiary@"
      "@error@"
      "@surface@"
      "@surface_variant@"
      "@on_surface@"
      "@on_surface_variant@"
      "@outline@"
    ]
    [
      colors.mPrimary
      colors.mSecondary
      colors.mTertiary
      colors.mError
      colors.mSurface
      colors.mSurfaceVariant
      colors.mOnSurface
      colors.mOnSurfaceVariant
      colors.mOutline
    ]
    template;
in {
  programs.starship = {
    enable = true;
  };

  home.file.".config/starship.toml".text = starshipConfig;
}
