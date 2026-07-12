{inputs, ...}: {
  config.retr0astic.homeModules.base = {
    imports = [
      {_module.args.spicetifyNix = inputs.spicetify-nix;}
      ../../modules/home
    ];
  };
}
