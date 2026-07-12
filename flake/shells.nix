{inputs, ...}: {
  config.retr0astic.shells.noctalia = {
    home = {
      imports = [
        inputs.noctalia.homeModules.default
        (import ./_shell/noctalia.nix {})
      ];
    };
  };
}
