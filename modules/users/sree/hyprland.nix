{...}: {
  flake.modules.homeManager.sree = {
    config,
    lib,
    ...
  }: let
    inherit (lib.generators) mkLuaInline;

    luaBind = key: dispatcher: {
      _args = [
        (mkLuaInline key)
        (mkLuaInline dispatcher)
      ];
    };

    key = suffix: ''mainMod .. " + ${suffix}"'';
    exec = command: ''hl.dsp.exec_cmd(${command})'';
  in {
    wayland.windowManager.hyprland.settings.on = lib.mkIf config.wayland.windowManager.hyprland.enable (lib.mkAfter [
      {
        _args = [
          "hyprland.start"
          (mkLuaInline ''
            function()
              hl.exec_cmd("spotify")
              hl.exec_cmd("vesktop")
            end
          '')
        ];
      }
    ]);

    wayland.windowManager.hyprland.settings.bind = lib.mkIf config.wayland.windowManager.hyprland.enable (lib.mkAfter [
      (luaBind (key "A") ''hl.dsp.workspace.toggle_special("chat")'')
      (luaBind (key "SHIFT + A") ''hl.dsp.window.move({ workspace = "special:chat" })'')
      (luaBind (key "M") ''hl.dsp.workspace.toggle_special("media")'')
      (luaBind (key "SHIFT + M") ''hl.dsp.window.move({ workspace = "special:media" })'')
      (luaBind (key "CTRL + A") (exec ''"vesktop"''))
      (luaBind (key "CTRL + M") (exec ''"spotify"''))
    ]);

    wayland.windowManager.hyprland.settings.window_rule = lib.mkIf config.wayland.windowManager.hyprland.enable (lib.mkAfter [
      {
        match.class = "(vesktop|Vesktop)";
        workspace = "special:chat silent";
      }
      {
        match.class = "zen";
        match.title = ".*WhatsApp.*";
        workspace = "special:chat silent";
      }
      {
        match.class = "(Spotify|spotify)";
        workspace = "special:media silent";
      }
      {
        match.class = "(Spotify|spotify)";
        idle_inhibit = "focus";
      }
    ]);
  };
}
