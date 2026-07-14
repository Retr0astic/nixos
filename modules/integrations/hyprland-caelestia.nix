{...}: {
  config.retr0astic.integrations.hyprland-caelestia = {
    desktop = "hyprland";
    shell = "caelestia";
    home = {lib, ...}: {
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
        bindi = lib.mkAfter [
          {
            _args = ["SUPER" "Super_L" "global" "caelestia:launcher"];
          }
        ];

        bindin = lib.mkAfter [
          {
            _args = ["SUPER" "catchall" "global" "caelestia:launcherInterrupt"];
          }
          {
            _args = ["SUPER" "mouse:272" "global" "caelestia:launcherInterrupt"];
          }
          {
            _args = ["SUPER" "mouse:273" "global" "caelestia:launcherInterrupt"];
          }
          {
            _args = ["SUPER" "mouse:274" "global" "caelestia:launcherInterrupt"];
          }
          {
            _args = ["SUPER" "mouse:275" "global" "caelestia:launcherInterrupt"];
          }
          {
            _args = ["SUPER" "mouse:276" "global" "caelestia:launcherInterrupt"];
          }
          {
            _args = ["SUPER" "mouse:277" "global" "caelestia:launcherInterrupt"];
          }
          {
            _args = ["SUPER" "mouse_up" "global" "caelestia:launcherInterrupt"];
          }
          {
            _args = ["SUPER" "mouse_down" "global" "caelestia:launcherInterrupt"];
          }
        ];
      };
    };
  };
}
