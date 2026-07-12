{inputs, ...}: {
  config.retr0astic.nixosModules.zen = {
    imports = [
      {_module.args.zenBrowser = inputs.zenBrowser;}
      ../../modules/zen.nix
    ];
  };
}
