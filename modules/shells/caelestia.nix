{
  config,
  inputs,
  ...
}: let
  inherit (config.flake.lib.hypr) mkLuaInline globalBind;
in {
  # Pull the home-manager side in whenever this module is selected.
  flake.modules.nixos.caelestia = {
    home-manager.sharedModules = [config.flake.modules.homeManager.caelestia];
  };

  flake.modules.homeManager.caelestia = {
    config,
    lib,
    ...
  }: {
    imports = [inputs.caelestia-shell.homeManagerModules.default];

    programs.caelestia = {
      enable = true;
      cli.enable = true;
      systemd.enable = false;
    };

    # Hyprland glue. It applies only when hyprland is part of the same
    # configuration, so caelestia stays usable under any other desktop.
    wayland.windowManager.hyprland.settings = lib.mkIf config.wayland.windowManager.hyprland.enable {
      on = lib.mkBefore [
        {
          _args = [
            "hyprland.start"
            (mkLuaInline ''
              function()
                hl.exec_cmd("caelestia shell -d")
              end
            '')
          ];
        }
      ];

      # Caelestia's upstream dotfiles use Super on its own for the launcher.
      # The interrupt bindings keep Super+key and Super+mouse shortcuts from
      # opening the launcher after their normal action is handled.
      bind = lib.mkAfter [
        (globalBind "SUPER + Super_L" "caelestia:launcher" {ignore_mods = true;})
        (globalBind "SUPER + mouse:272" "caelestia:launcherInterrupt" {
          ignore_mods = true;
          non_consuming = true;
        })
        (globalBind "SUPER + mouse:273" "caelestia:launcherInterrupt" {
          ignore_mods = true;
          non_consuming = true;
        })
        (globalBind "SUPER + mouse:274" "caelestia:launcherInterrupt" {
          ignore_mods = true;
          non_consuming = true;
        })
        (globalBind "SUPER + mouse:275" "caelestia:launcherInterrupt" {
          ignore_mods = true;
          non_consuming = true;
        })
        (globalBind "SUPER + mouse:276" "caelestia:launcherInterrupt" {
          ignore_mods = true;
          non_consuming = true;
        })
        (globalBind "SUPER + mouse:277" "caelestia:launcherInterrupt" {
          ignore_mods = true;
          non_consuming = true;
        })
        (globalBind "SUPER + mouse_up" "caelestia:launcherInterrupt" {
          ignore_mods = true;
          non_consuming = true;
        })
        (globalBind "SUPER + mouse_down" "caelestia:launcherInterrupt" {
          ignore_mods = true;
          non_consuming = true;
        })
      ];

      # `catchall` is a Hyprland keyword, not an XKB keysym. Keep it out of
      # the Lua binding helper, which parses key combinations as keysyms.
    };
  };
}
