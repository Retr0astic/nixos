{inputs, ...}: {
  config.retr0astic.features.fonts = {
    imports = [
      {_module.args.lucidglyph = inputs.lucidglyph;}
      ../../modules/lucidglyph.nix
    ];
  };
}
