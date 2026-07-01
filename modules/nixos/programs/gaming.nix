{pkgs, ...}: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
    extraCompatPackages = [pkgs.proton-ge-bin];
  };

  programs.gamescope.enable = true;
  programs.gamemode = {
    enable = true;
    settings.cpu = {
      apply_governors = 1;
      desiredgov = "performance";
    };
  };

  environment.systemPackages = [
    (pkgs.heroic.override {
      extraPkgs = pkgs':
        with pkgs'; [
          gamescope
          gamemode
        ];
    })
  ];
}
