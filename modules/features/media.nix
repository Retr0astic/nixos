{config, ...}: {
  # Media players and viewers. Desktop-only: bigrig does not name this.
  flake.modules.nixos.media = {
    home-manager.sharedModules = [config.flake.modules.homeManager.media];
  };

  flake.modules.homeManager.media = {pkgs, ...}: {
    home.packages = with pkgs; [
      mpv
      loupe
      swayimg
      playerctl
    ];
  };
}
