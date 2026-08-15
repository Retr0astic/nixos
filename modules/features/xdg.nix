{...}: {
  config.retr0astic.features.xdg.home = {config, ...}: {
    xdg.userDirs = {
      enable = true;
      createDirectories = true;
      documents = "${config.home.homeDirectory}/Documents";
      download = "${config.home.homeDirectory}/Downloads";
      pictures = "${config.home.homeDirectory}/Pictures";
      music = "${config.home.homeDirectory}/Music";
      videos = "${config.home.homeDirectory}/Videos";
      desktop = "${config.home.homeDirectory}/Desktop";
      templates = "${config.home.homeDirectory}/Templates";
      publicShare = "${config.home.homeDirectory}/Public";
    };
  };
  config.retr0astic.features.system-packages.system = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      xdg-utils
    ];
  };
}
