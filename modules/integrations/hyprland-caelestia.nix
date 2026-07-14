{...}: {
  config.retr0astic.integrations.hyprland-caelestia = {
    desktop = "hyprland";
    shell = "caelestia";
    home = {lib, ...}: let
      inherit (lib.generators) mkLuaInline;

      globalBind = key: shortcut: options: {
        _args = [
          (mkLuaInline ''"${key}"'')
          (mkLuaInline ''hl.dsp.global("${shortcut}")'')
          options
        ];
      };
    in {
      wayland.windowManager.hyprland.settings = {
        on = lib.mkBefore [
          {
            _args = [
              "hyprland.start"
              (lib.generators.mkLuaInline ''
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
  };
}
