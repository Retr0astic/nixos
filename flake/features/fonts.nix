{inputs, ...}: {
  config.retr0astic.nixosModules.lucidglyph = {
    imports = [
      {_module.args.lucidglyph = inputs.lucidglyph;}
      ../../modules/lucidglyph.nix
    ];
  };
}
