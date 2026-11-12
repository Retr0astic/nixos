{inputs, ...}: {
  flake.modules.homeManager.umbriel = {pkgs, ...}: {
    imports = [inputs.umbriel.homeModules.default];

    programs.umbriel.enable = true;

    # Matches home.packages in modules/desktops/hyprland/settings.nix.
    # Screenshots go through noctalia's own commands (see the screenshot
    # submap in modules/shells/noctalia.nix), so no hyprshot here either.
    home.packages = [pkgs.wl-clipboard pkgs.wlsunset];

    # Idle, lock and suspend come from noctalia's own [idle] config, as on
    # the Hyprland side (modules/desktops/hyprland/session.nix). hypridle ran
    # the same lock and suspend timeouts a second time and had no screen-off.
    services.hypridle.enable = false;

    systemd.user.sessionVariables = {
      XDG_CURRENT_DESKTOP = "Umbriel";
      XDG_SESSION_TYPE = "wayland";
    };
  };
}
