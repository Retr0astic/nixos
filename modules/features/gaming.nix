{config, ...}: {
  flake.modules.nixos.gaming = {pkgs, ...}: {
    home-manager.sharedModules = [config.flake.modules.homeManager.gaming];

    programs = {
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        gamescopeSession.enable = true;
        extraCompatPackages = [pkgs.proton-ge-bin];
      };
      gamescope.enable = true;
      gamemode = {
        enable = true;
        settings.cpu = {
          apply_governors = 1;
          desiredgov = "performance";
        };
      };
    };
    environment.systemPackages = [(pkgs.heroic.override {extraPkgs = pkgs': with pkgs'; [gamescope gamemode];})];
  };

  flake.modules.homeManager.gaming = {pkgs, ...}: {
    home.packages = with pkgs; [gamescope-wsi mangohud ludusavi protonup-qt];
  };
}
