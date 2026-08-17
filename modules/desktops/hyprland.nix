{
  config,
  inputs,
  ...
}: {
  flake.modules.nixos.hyprland = {pkgs, ...}: let
    hyprland = inputs.hyprland;
  in {
    home-manager.sharedModules = [config.flake.modules.homeManager.hyprland];

    programs.hyprland = {
      enable = true;
      withUWSM = true;
      package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
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
