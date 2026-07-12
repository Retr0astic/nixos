{inputs, ...}: {
  config.retr0astic.homeModules.base = {
    imports = [
      ../../modules/home
    ];
  };
  config.retr0astic.homeModules.spicetify = {pkgs, ...}:
    import ../../modules/home/programs/spicetify.nix {
      inherit pkgs;
      spicetifyNix = inputs.spicetify-nix;
    };
}
