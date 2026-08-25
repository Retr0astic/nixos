{config, ...}: {
  flake.modules.nixos.hyprland = {pkgs, ...}: {
    home-manager.sharedModules = [config.flake.modules.homeManager.hyprland];

    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    services.displayManager.defaultSession = "hyprland";

    environment.systemPackages = with pkgs; [
      hyprpolkitagent
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];

    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
      config.hyprland = {
        default = [
          "hyprland"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Settings" = ["gtk"];
      };
    };
  };
}
