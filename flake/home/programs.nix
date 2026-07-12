{inputs, ...}: {
  config.retr0astic.homeModules.programs = {
    imports = [
      ./_modules/programs-documents.nix
      ({pkgs, ...}: import ./_modules/programs-spicetify.nix {inherit pkgs; spicetifyNix = inputs.spicetify-nix;})
    ];
  };
}
