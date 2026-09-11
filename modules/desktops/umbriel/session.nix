{inputs, ...}: {
  flake.modules.homeManager.umbriel = {pkgs, ...}: {
    imports = [inputs.umbriel.homeModules.default];

    programs.umbriel.enable = true;

    # Matches home.packages in modules/desktops/hyprland/settings.nix.
    # hyprshot is dropped — it needs hyprctl, and its role is covered by
    # noctalia's own screenshot commands (see the keybinds in config.toml).
    home.packages = [pkgs.cliphist pkgs.wlsunset];

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "noctalia msg session lock";
          before_sleep_cmd = "noctalia msg session lock";
          ignore_dbus_inhibit = false;
          ignore_systemd_inhibit = false;
          ignore_wayland_inhibit = false;
        };

        listener = [
          {
            timeout = 600;
            on-timeout = "noctalia msg session lock";
          }
          {
            timeout = 900;
            on-timeout = "noctalia msg session lock-and-suspend";
          }
        ];
      };
    };

    systemd.user.sessionVariables = {
      XDG_CURRENT_DESKTOP = "Umbriel";
      XDG_SESSION_TYPE = "wayland";
    };
  };
}
