{config, ...}: let
  inherit (config.flake.lib.hypr) luaBind luaBindWith key exec;
in {
  flake.modules.homeManager.hyprland = {lib, ...}: {
    wayland.windowManager.hyprland.extraConfig = ''
      hl.define_submap("screenshot", function()
        hl.bind("Escape", hl.dsp.submap("reset"))
        hl.bind("w", function()
          hl.dispatch(hl.dsp.exec_cmd("hyprshot -m window --clipboard-only"))
          hl.dispatch(hl.dsp.submap("reset"))
        end)
        hl.bind("o", function()
          hl.dispatch(hl.dsp.exec_cmd("hyprshot -m output --clipboard-only"))
          hl.dispatch(hl.dsp.submap("reset"))
        end)
        hl.bind("r", function()
          hl.dispatch(hl.dsp.exec_cmd("hyprshot -m region -z --clipboard-only"))
          hl.dispatch(hl.dsp.submap("reset"))
        end)
        hl.bind("SHIFT + w", function()
          hl.dispatch(hl.dsp.exec_cmd("hyprshot -m window"))
          hl.dispatch(hl.dsp.submap("reset"))
        end)
        hl.bind("SHIFT + o", function()
          hl.dispatch(hl.dsp.exec_cmd("hyprshot -m output"))
          hl.dispatch(hl.dsp.submap("reset"))
        end)
        hl.bind("SHIFT + r", function()
          hl.dispatch(hl.dsp.exec_cmd("hyprshot -m region -z"))
          hl.dispatch(hl.dsp.submap("reset"))
        end)
      end)

      hl.define_submap("group", function()
        hl.bind("Escape", hl.dsp.submap("reset"))
        hl.bind("t", hl.dsp.group.toggle())
        hl.bind("n", hl.dsp.group.next())
        hl.bind("p", hl.dsp.group.prev())
        hl.bind("l", hl.dsp.group.lock())
        hl.bind("m", hl.dsp.group.move_window())
      end)
    '';

    wayland.windowManager.hyprland.settings.bind =
      [
        (luaBind (key "Return") (exec "terminal"))
        (luaBind (key "SHIFT + Return") (exec "browser"))
        (luaBind (key "C") "hl.dsp.window.close()")
        (luaBind (key "CTRL + Escape") "hl.dsp.exit()")
        (luaBind (key "E") (exec "fileManager"))
        (luaBind (key "V") ''hl.dsp.window.float({ action = "toggle" })'')
        (luaBind (key "P") "hl.dsp.window.pseudo()")

        (luaBind (key "left") ''hl.dsp.focus({ direction = "left" })'')
        (luaBind (key "right") ''hl.dsp.focus({ direction = "right" })'')
        (luaBind (key "up") ''hl.dsp.focus({ direction = "up" })'')
        (luaBind (key "down") ''hl.dsp.focus({ direction = "down" })'')

        (luaBind (key "S") ''hl.dsp.workspace.toggle_special("scratch")'')
        (luaBind (key "SHIFT + S") ''hl.dsp.window.move({ workspace = "special:scratch" })'')
        (luaBind (key "G") ''hl.dsp.focus({ workspace = "name:games" })'')
        (luaBind (key "SHIFT + G") ''hl.dsp.window.move({ workspace = "name:games" })'')
        (luaBind (key "mouse_down") ''hl.dsp.focus({ workspace = "e+1" })'')
        (luaBind (key "mouse_up") ''hl.dsp.focus({ workspace = "e-1" })'')

        (luaBind ''"print"'' ''hl.dsp.submap("screenshot")'')

        (luaBind (key "T") ''hl.dsp.submap("group")'')

        (luaBind (key "D") ''hl.dsp.dpms({ action = "on" })'')
        (luaBind (key "SHIFT + D") ''hl.dsp.dpms({ action = "off" })'')

        (luaBindWith (key "mouse:272") "hl.dsp.window.drag()" {mouse = true;})
        (luaBindWith (key "mouse:273") "hl.dsp.window.resize()" {mouse = true;})

        (luaBindWith ''"XF86AudioRaiseVolume"'' (exec ''"wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"'') {
          locked = true;
          repeating = true;
        })
        (luaBindWith ''"XF86AudioLowerVolume"'' (exec ''"wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"'') {
          locked = true;
          repeating = true;
        })
        (luaBindWith ''"XF86AudioMute"'' (exec ''"wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"'') {
          locked = true;
          repeating = true;
        })
        (luaBindWith ''"XF86AudioMicMute"'' (exec ''"wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"'') {
          locked = true;
          repeating = true;
        })
        (luaBindWith ''"XF86MonBrightnessUp"'' (exec ''"brightnessctl -e4 -n2 set 5%+"'') {
          locked = true;
          repeating = true;
        })
        (luaBindWith ''"XF86MonBrightnessDown"'' (exec ''"brightnessctl -e4 -n2 set 5%-"'') {
          locked = true;
          repeating = true;
        })

        (luaBindWith ''"XF86AudioNext"'' (exec ''"playerctl next"'') {locked = true;})
        (luaBindWith ''"XF86AudioPause"'' (exec ''"playerctl play-pause"'') {locked = true;})
        (luaBindWith ''"XF86AudioPlay"'' (exec ''"playerctl play-pause"'') {locked = true;})
        (luaBindWith ''"XF86AudioPrev"'' (exec ''"playerctl previous"'') {locked = true;})
      ]
      ++ (lib.concatLists (lib.genList (
          i: let
            workspace = toString (i + 1);
            keyNum =
              if i == 9
              then "0"
              else toString (i + 1);
          in [
            (luaBind (key keyNum) ''hl.dsp.focus({ workspace = "${workspace}" })'')
            (luaBind (key "SHIFT + ${keyNum}") ''hl.dsp.window.move({ workspace = "${workspace}" })'')
          ]
        )
        10));
  };
}
