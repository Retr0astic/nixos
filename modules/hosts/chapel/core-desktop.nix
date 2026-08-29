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

    # `glib` is here for the gsettings binary, beside the schema path it
    # reads. dconf and gsettings-desktop-schemas are NOT listed as packages:
    # programs.dconf.enable and services.dbus.packages already install them.
    environment.systemPackages = [pkgs.glib];
  };
}
