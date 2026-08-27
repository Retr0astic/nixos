{
  config,
  inputs,
  ...
}: {
  # Pull the home-manager side in whenever this module is selected.
  flake.modules.nixos.noctalia = {
    home-manager.sharedModules = [config.flake.modules.homeManager.noctalia];
  };

  flake.modules.homeManager.noctalia = {
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
    # home-manager now ships its own programs.noctalia module upstream,
    # which collides with noctalia's own module below. Keep the
    # noctalia-provided one — this config relies on its options (e.g.
    # systemd.enable) which the upstream module doesn't necessarily match.
    disabledModules = ["${inputs.home-manager}/modules/programs/noctalia.nix"];
    imports = [inputs.noctalia.homeModules.default];

    programs.noctalia = {
      enable = true;
      systemd.enable = false;
    };

    programs.fish.functions.noctalia-config = ''
      set -l tmp (mktemp "${config.home.homeDirectory}/nixos/modules/noctalia/config.toml.XXXXXX")
      if test $status -ne 0
        echo "noctalia-config: could not create temporary file" >&2
        return 1
      end

      if noctalia config export >$tmp
        mv -- $tmp ${config.home.homeDirectory}/nixos/modules/noctalia/config.toml
        if test $status -eq 0
          echo "noctalia-config: exported configuration"
          return 0
        end
      end

      rm -f $tmp
      echo "noctalia-config: export failed; configuration was not replaced" >&2
      return 1
    '';

    home.file.".config/noctalia".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/modules/noctalia";

    programs.kitty.extraConfig = lib.mkIf config.programs.kitty.enable ''
      include themes/noctalia.conf
    '';

    # Hyprland glue. It applies only when hyprland is part of the same
    # configuration, so noctalia stays usable under any other desktop.
    wayland.windowManager.hyprland = lib.mkIf config.wayland.windowManager.hyprland.enable {
      extraConfig = ''
        local hm_xdg_config_home = os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config"
        package.path = hm_xdg_config_home .. "/hypr/?.lua;" .. hm_xdg_config_home .. "/hypr/?/init.lua;" .. package.path
        require("noctalia").apply_theme()

        hl.layer_rule({
          name = "noctalia",
          match = {
            namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
          },
          no_anim = true,
          ignore_alpha = 0.5,
          blur = true,
          blur_popups = true,
        })
      '';

      settings = {
        ipc._var = "noctalia msg";
        menu._var = mkLuaInline ''ipc .. " panel-toggle launcher"'';

        on = lib.mkBefore [
          {
            _args = [
              "hyprland.start"
              (mkLuaInline ''
                function()
                  hl.exec_cmd("noctalia")
                end
              '')
            ];
          }
        ];

        bind = lib.mkAfter [
          (luaBind (key "R") (exec "menu"))
          (luaBind (key "Z") (exec ''ipc .. " panel-toggle control-center"''))
          (luaBind (key "comma") (exec ''ipc .. " settings-toggle"''))
          (luaBind (key "SHIFT + C") (exec ''ipc .. " panel-toggle launcher clipboard"''))
          (luaBind (key "D") (exec ''ipc .. " caffeine-disable"''))
          (luaBind (key "SHIFT + D") (exec ''ipc .. " caffeine-enable"''))
        ];
      };
    };

    # Starship reads the palette that noctalia writes to its cache.
    home.activation.starshipNoctaliaPalette = lib.mkIf config.programs.starship.enable (lib.hm.dag.entryAfter ["writeBoundary"] ''
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
    '');
  };
}
