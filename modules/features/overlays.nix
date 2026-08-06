{...}: {
  config.retr0astic.features.overlays.system = {...}: {
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
}
