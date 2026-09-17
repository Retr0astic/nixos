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
    ];

    # playerctld tracks which MPRIS player was active last and answers as a
    # player itself. Without it, a bare `playerctl play-pause` picks the
    # first player on the bus, which is the music app whether or not it is
    # the thing you are listening to. The media keys therefore ask for
    # `playerctld,%any`: the last active player, or any player if the daemon
    # is not up yet.
    #
    # The module installs playerctl, so this aspect must not list it again.
    services.playerctld.enable = true;
  };
}
