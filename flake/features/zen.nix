{inputs, ...}: {
  config.retr0astic.features.zen = {
    imports = [
      {_module.args.zenBrowser = inputs.zenBrowser;}
      ../../modules/zen.nix
    ];
  };
}
