{config, ...}: { config.retr0astic.desktops.hyprland.home = {lib, ...}: let
  inherit (lib.generators) mkLuaInline;

  luaBind = key: dispatcher: {
    _args = [
      (mkLuaInline key)
      (mkLuaInline dispatcher)
    ];
  };

  luaBindWith = key: dispatcher: options: {
    _args = [
      (mkLuaInline key)
      (mkLuaInline dispatcher)
      options
    ];
  };

  key = suffix: ''mainMod .. " + ${suffix}"'';
  exec = command: ''hl.dsp.exec_cmd(${command})'';
in {
  wayland.windowManager.hyprland.settings.bind =
    [
      (luaBind (key "Return") (exec "terminal"))
      (luaBind (key "C") "hl.dsp.window.close()")
      (luaBind (key "CTRL + Escape") "hl.dsp.exit()")
      (luaBind (key "E") (exec "fileManager"))
      (luaBind (key "V") ''hl.dsp.window.float({ action = "toggle" })'')
      (luaBind (key "R") (exec "menu"))
      (luaBind (key "P") "hl.dsp.window.pseudo()")
      (luaBind (key "Z") (exec ''ipc .. " panel-toggle control-center"''))
      (luaBind (key "comma") (exec ''ipc .. " settings-toggle"''))
      (luaBind (key "SHIFT + C") (exec ''ipc .. " panel-toggle launcher clipboard"''))

      (luaBind (key "left") ''hl.dsp.focus({ direction = "left" })'')
      (luaBind (key "right") ''hl.dsp.focus({ direction = "right" })'')
      (luaBind (key "up") ''hl.dsp.focus({ direction = "up" })'')
      (luaBind (key "down") ''hl.dsp.focus({ direction = "down" })'')

      (luaBind (key "S") ''hl.dsp.workspace.toggle_special("scratch")'')
      (luaBind (key "SHIFT + S") ''hl.dsp.window.move({ workspace = "special:scratch" })'')
      (luaBind (key "A") ''hl.dsp.workspace.toggle_special("chat")'')
      (luaBind (key "SHIFT + A") ''hl.dsp.window.move({ workspace = "special:chat" })'')
      (luaBind (key "M") ''hl.dsp.workspace.toggle_special("media")'')
      (luaBind (key "SHIFT + M") ''hl.dsp.window.move({ workspace = "special:media" })'')

      (luaBind (key "CTRL + A") (exec ''"vesktop"''))
      (luaBind (key "CTRL + M") (exec ''"spotify"''))

      (luaBind (key "mouse_down") ''hl.dsp.focus({ workspace = "e+1" })'')
      (luaBind (key "mouse_up") ''hl.dsp.focus({ workspace = "e-1" })'')

      (luaBind (key "print") (exec ''"hyprshot -m window --clipboard-only"''))
      (luaBind ''"print"'' (exec ''"hyprshot -m output --clipboard-only"''))
      (luaBind ''"SHIFT + print"'' (exec ''"hyprshot -m region --clipboard-only"''))
      (luaBind ''"CTRL + print"'' (exec ''"hyprshot -m window"''))
      (luaBind ''"CTRL + " .. mainMod .. " + print"'' (exec ''"hyprshot -m output"''))
      (luaBind ''"CTRL + SHIFT + print"'' (exec ''"hyprshot -m region"''))

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
}
; }
