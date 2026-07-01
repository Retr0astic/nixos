{config, ...}: {
  programs.starship = {
    enable = true;
  };

  home.file.".config/starship.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/modules/starship/starship.toml";
}
