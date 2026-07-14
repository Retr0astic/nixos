{...}: {
  config.retr0astic.integrations.hyprland-caelestia = {
    desktop = "hyprland";
    shell = "caelestia";
    home = {lib, ...}: {
      wayland.windowManager.hyprland.settings.on = lib.mkBefore [
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
    };
  };
}
