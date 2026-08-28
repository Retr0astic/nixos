{...}: {
  # Desktop-only half of core.nix, split out so headless hosts (bigrig) can
  # take core without Wayland/Qt session variables and dconf. Only chapel
  # imports this.
  flake.modules.nixos.core-desktop = {pkgs, ...}: {
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      SDL_VIDEODRIVER = "wayland";
      GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";
      SAL_USE_VCLPLUGIN = "qt6";
    };
    programs.dconf.enable = true;
  };
}
