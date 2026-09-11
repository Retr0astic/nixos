{config, ...}: let
  inherit (config.flake.lib.hypr) mkLuaInline luaBind key exec;
in {
  flake.modules.homeManager.sree = {
    config,
    lib,
    ...
  }: {
    wayland.windowManager.hyprland.settings.on = lib.mkIf config.wayland.windowManager.hyprland.enable (lib.mkAfter [
      {
        _args = [
          "hyprland.start"
          (mkLuaInline ''
            function()
              hl.exec_cmd("spotify")
              hl.exec_cmd("vesktop")
              hl.exec_cmd("easyeffects --gapplication-service")

              -- The "silent" rules below open windows into a special
              -- workspace that has never been shown. Hyprland leaves such a
              -- workspace at alpha 1, and from then on blocks solitary mode
              -- (and so direct scanout) for every fullscreen game:
              -- `hyprctl monitors` reports solitaryBlockedBy WORKSPACES.
              -- Showing and hiding each one once animates it to alpha 0.
              -- The delay lets the autostart apps map first.
              hl.timer(function()
                for _, ws in ipairs({"chat", "media"}) do
                  hl.dispatch(hl.dsp.workspace.toggle_special(ws))
                  hl.dispatch(hl.dsp.workspace.toggle_special(ws))
                end
              end, {timeout = 15000, type = "oneshot"})
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
