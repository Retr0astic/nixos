{...}: {
  config.retr0astic.features.gaming.system = {pkgs, ...}: {
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

  config.retr0astic.features.gaming.home = {pkgs, ...}: {
    home.packages = with pkgs; [gamescope-wsi mangohud ludusavi protonup-qt];
  };
}
