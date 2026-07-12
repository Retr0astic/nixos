{inputs, ...}: {
  config.retr0astic.shells.noctalia = {
    home = {
      imports = [
        inputs.noctalia.homeModules.default
        ../modules/home/shells/noctalia.nix
      ];
    };
  };
}
