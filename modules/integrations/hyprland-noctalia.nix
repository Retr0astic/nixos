{...}: {
  config.retr0astic.integrations.hyprland-noctalia = {
    desktop = "hyprland";
    shell = "noctalia";
    home = {config, lib, ...}: lib.mkMerge [
      {
        wayland.windowManager.hyprland = {
          extraConfig = ''
            local hm_xdg_config_home = os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config"
            package.path = hm_xdg_config_home .. "/hypr/?.lua;" .. hm_xdg_config_home .. "/hypr/?/init.lua;" .. package.path
            require("noctalia").apply_theme()
          '';

          settings = {
            ipc._var = "noctalia msg";
            menu._var = lib.generators.mkLuaInline ''ipc .. " panel-toggle launcher"'';

            on = lib.mkBefore [
              {
                _args = [
                  "hyprland.start"
                  (lib.generators.mkLuaInline ''
                    function()
                      hl.exec_cmd("noctalia")
                    end
                  '')
                ];
              }
            ];

            bind = lib.mkAfter (let
              key = suffix: ''mainMod .. " + ${suffix}"'';
              exec = command: ''hl.dsp.exec_cmd(${command})'';
              luaBind = key: dispatcher: {
                _args = [
                  (lib.generators.mkLuaInline key)
                  (lib.generators.mkLuaInline dispatcher)
                ];
              };
            in [
              (luaBind (key "R") (exec "menu"))
              (luaBind (key "Z") (exec ''ipc .. " panel-toggle control-center"''))
              (luaBind (key "comma") (exec ''ipc .. " settings-toggle"''))
              (luaBind (key "SHIFT + C") (exec ''ipc .. " panel-toggle launcher clipboard"''))
            ]);

            layer_rule = {
              match.namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd)$";
              ignore_alpha = 0.5;
              blur = true;
              blur_popups = true;
            };
          };
        };
      }

      (lib.mkIf config.programs.starship.enable {
        home.activation.starshipNoctaliaPalette = lib.hm.dag.entryAfter ["writeBoundary"] ''
          config_dir="''${XDG_CONFIG_HOME:-$HOME/.config}"
          cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}"
          base_file="$config_dir/starship/base.toml"
          config_file="$config_dir/starship.toml"
          palette_file="$cache_dir/noctalia/starship-palette.toml"
          marker_begin="# >>> NOCTALIA STARSHIP PALETTE >>>"
          marker_end="# <<< NOCTALIA STARSHIP PALETTE <<<"

          mkdir -p "$(dirname "$config_file")"
          install -m 0644 "$base_file" "$config_file"

          if [ -f "$palette_file" ]; then
            {
              echo
              echo "$marker_begin"
              cat "$palette_file"
              echo "$marker_end"
            } >> "$config_file"
          fi
        '';
      })
    ];
  };
}
