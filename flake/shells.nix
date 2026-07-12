{inputs, ...}: {
  config.retr0astic.shells.noctalia = {
    home = {
      imports = [
        {_module.args.noctalia = inputs.noctalia;}
        ../modules/home/shells/noctalia.nix
      ];
    };
  };
}
