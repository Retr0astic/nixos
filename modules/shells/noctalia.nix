{
  config,
  inputs,
  ...
}: let
  inherit (config.flake.lib.hypr) mkLuaInline luaBind key exec;

  # The hassio plugin token stays out of the public config.toml. sops renders
  # it here, and config.toml pulls it in with [include].
  hassioTokenFile = "/run/secrets/rendered/noctalia-hassio.toml";
in {
  # Pull the home-manager side in whenever this module is selected.
  flake.modules.nixos.noctalia = osArgs: {
    home-manager.sharedModules = [config.flake.modules.homeManager.noctalia];

    sops.secrets.hassio_token = {};
    sops.templates."noctalia-hassio.toml" = {
      path = hassioTokenFile;
      owner = "sree";
      content = ''
        [plugin_settings."pozzoo/hassio"]
        ha_token = "${osArgs.config.sops.placeholder.hassio_token}"
      '';
    };
  };

  flake.modules.homeManager.noctalia = {
    config,
    lib,
    pkgs,
    ...
  }: {
    # home-manager now ships its own programs.noctalia module upstream,
    # which collides with noctalia's own module below. Keep the
    # noctalia-provided one — this config relies on its options (e.g.
    # systemd.enable) which the upstream module doesn't necessarily match.
    disabledModules = ["${inputs.home-manager}/modules/programs/noctalia"];
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

      # Export flattens the include into the output. Drop the token and put
      # the [include] back so the secret never lands in git.
      if begin
          printf '%s\n' '[include]' 'files = ["${hassioTokenFile}"]' ""
          noctalia config export | string match -rv '^\s*ha_token\s*='
          test $pipestatus[1] -eq 0
        end >$tmp
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

        hl.define_submap("screenshot", function()
          hl.bind("Escape", hl.dsp.submap("reset"))
          hl.bind("r", function()
            hl.dispatch(hl.dsp.exec_cmd("noctalia msg screenshot-region"))
            hl.dispatch(hl.dsp.submap("reset"))
          end)
          hl.bind("o", function()
            hl.dispatch(hl.dsp.exec_cmd("noctalia msg screenshot-fullscreen monitor"))
            hl.dispatch(hl.dsp.submap("reset"))
          end)
          hl.bind("SHIFT + o", function()
            hl.dispatch(hl.dsp.exec_cmd("noctalia msg screenshot-fullscreen all"))
            hl.dispatch(hl.dsp.submap("reset"))
          end)
          hl.bind("a", function()
            hl.dispatch(hl.dsp.exec_cmd("noctalia msg screenshot-annotate"))
            hl.dispatch(hl.dsp.submap("reset"))
          end)
        end)
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
          (luaBind ''"ALT + Tab"'' (exec ''ipc .. " window-switcher"''))
          (luaBind ''"print"'' ''hl.dsp.submap("screenshot")'')
        ];
      };
    };

    # Umbriel glue. Deployed in every build, not only the umbriel one:
    # noctalia's umbriel color template writes a stub config.toml whenever
    # the file is missing. A build without umbriel would drop the link, the
    # stub would take its place, and the next umbriel build would collide.
    home.file.".config/umbriel/config.toml".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/modules/umbriel/config.toml";

    # The same binds and layer rule as the Hyprland glue above. config.toml
    # pulls this file in with [include]; Umbriel merges [keybinds] by key.
    # Mod+D and Mod+Shift+D stay in config.toml, since they also run DPMS
    # and OpenRGB.
    home.file.".config/umbriel/noctalia-binds.toml".source = (pkgs.formats.toml {}).generate "noctalia-binds.toml" {
      keybinds = let
        ipc = "spawn noctalia msg";
        shot = cmd: {
          action = "${ipc} ${cmd}";
          submap = "reset";
        };
      in {
        "Mod" = "${ipc} panel-toggle launcher";
        "Mod+R" = "${ipc} panel-toggle launcher";
        "Mod+Z" = "${ipc} panel-toggle control-center";
        "Mod+Comma" = "${ipc} settings-toggle";
        "Mod+X" = "${ipc} settings-toggle";
        "Mod+Shift+C" = "${ipc} panel-toggle launcher clipboard";
        "Alt+Tab" = "${ipc} window-switcher";

        "Print" = {
          action = "submap screenshot";
          repeat = false;
        };
        "submap[screenshot],R" = shot "screenshot-region";
        "submap[screenshot],O" = shot "screenshot-fullscreen monitor";
        "submap[screenshot],Shift+O" = shot "screenshot-fullscreen all";
        "submap[screenshot],A" = shot "screenshot-annotate";
        "submap[screenshot],Escape" = "submap reset";
        "Shift+Print" = "${ipc} screenshot-fullscreen pick";
        "Ctrl+Print" = "${ipc} screenshot-annotate";
      };

      layer_rule = [
        {
          match.namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd|desktop-widget-[^\"]*)$";
          blur = true;
          blur_ignore_alpha = 0.5;
          blur_popups = true;
          blur_optimized = false;
        }
      ];
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
