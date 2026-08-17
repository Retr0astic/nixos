{
  config,
  inputs,
  ...
}: {
  # Pull the home-manager side in whenever this module is selected.
  flake.modules.nixos.spicetify = {
    home-manager.sharedModules = [config.flake.modules.homeManager.spicetify];
  };

  flake.modules.homeManager.spicetify = {pkgs, ...}: let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  in {
    imports = [inputs.spicetify-nix.homeManagerModules.default];
    programs.spicetify = {
      enable = true;
      enabledExtensions = with spicePkgs.extensions; [adblock hidePodcasts shuffle];
      enabledCustomApps = with spicePkgs.apps; [newReleases ncsVisualizer];
      enabledSnippets = with spicePkgs.snippets; [rotatingCoverart pointer];
      theme = spicePkgs.themes.text;
    };
  };
}
