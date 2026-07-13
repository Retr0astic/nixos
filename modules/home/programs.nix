{config, inputs, ...}: { config.retr0astic.features.programs.home = let spicetifyNix = inputs.spicetify-nix; in {
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
  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
      adjust-open = "width";
      recolor = true;
    };
  };
};
}
