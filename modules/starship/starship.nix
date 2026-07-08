{lib, ...}: let
  template = builtins.readFile ./starship.toml;
in {
  programs.starship = {
    enable = true;
  };

  home.file.".config/starship/base.toml".text = template;

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
}
