{config, ...}: {
  # File managers, their archive handlers, and the shared menu definition
  # that makes Dolphin's "Open With" list match the rest of the session.
  #
  # The nautilus overlay lives here rather than in a generic overlays module
  # so the package, its patch, and its menu wiring stay in one file.
  flake.modules.nixos.file-managers = {
    home-manager.sharedModules = [config.flake.modules.homeManager.file-managers];

    environment.etc."xdg/menus/applications.menu".source = ../dolphin.menu;

    nixpkgs.overlays = [
      (final: prev: {
        nautilus = prev.nautilus.overrideAttrs (old: {
          buildInputs =
            (old.buildInputs or [])
            ++ (with final.gst_all_1; [
              gst-plugins-good
              gst-plugins-bad
            ]);
        });
      })
    ];
  };

  flake.modules.homeManager.file-managers = {pkgs, ...}: {
    home.packages = with pkgs; [
      nautilus
      kdePackages.dolphin
      kdePackages.ark
      kdePackages.kio-extras
      p7zip
      unrar
    ];
  };
}
