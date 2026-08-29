{config, ...}: {
  # Pull the home-manager side in whenever this module is selected.
  flake.modules.nixos.appearance = {
    home-manager.sharedModules = [config.flake.modules.homeManager.appearance];
  };

  flake.modules.homeManager.appearance = {pkgs, ...}: {
    home.packages = with pkgs; [
      nwg-look
      adw-gtk3
      qt6Packages.qt6ct
    ];

    qt = {
      enable = true;
      platformTheme.name = "qt6ct";
    };
    home.pointerCursor = {
      enable = true;
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 16;
    };
    gtk = {
      enable = true;
      font = {
        name = "Rubik";
        size = 11;
      };
      cursorTheme = {
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
      };
      gtk3.extraConfig = {"gtk-cursor-theme-name" = "Bibata-Modern-Classic";};
      gtk4.extraConfig.Settings = ''gtk-cursor-theme-name=Bibata-Modern-Classic'';
    };
  };
}
