{
  config,
  inputs,
  ...
}: {
  flake.modules.nixos.umbriel = {pkgs, ...}: {
    imports = [inputs.umbriel.nixosModules.default];

    home-manager.sharedModules = [config.flake.modules.homeManager.umbriel];

    programs.umbriel = {
      enable = true;
      package = inputs.umbriel.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };

    services.displayManager.defaultSession = "umbriel";

    environment.systemPackages = [pkgs.xwayland-satellite];

    # Umbriel only imports a short, fixed list of session variables into
    # systemd --user on startup (WAYLAND_DISPLAY, DISPLAY, XDG_*,
    # UMBRIEL_SOCKET), unlike Hyprland's UWSM session, which also imports
    # PATH. Without this, `config.toml`'s `spawn:` commands (autostart
    # included) inherit only systemd's bare default PATH and can't find
    # user-profile binaries such as noctalia.
    systemd.user.services.umbriel.path = [
      "/run/wrappers"
      "/etc/profiles/per-user/sree"
      "/run/current-system/sw"
    ];
  };
}
