{
  spicetifyNix,
  pkgs,
  ...
}: {
  imports = [spicetifyNix.homeManagerModules.default];

  programs.spicetify = let
    spicePkgs = spicetifyNix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  in {
    enable = true;

    enabledExtensions = with spicePkgs.extensions; [
      adblock
      hidePodcasts
      shuffle
    ];
    enabledCustomApps = with spicePkgs.apps; [
      newReleases
      ncsVisualizer
    ];
    enabledSnippets = with spicePkgs.snippets; [
      rotatingCoverart
      pointer
    ];

    theme = spicePkgs.themes.text;
  };
}
