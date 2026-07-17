{
  config,
  inputs,
  ...
}: {
  config.retr0astic.shells.noctalia.home = {
    config,
    lib,
    ...
  }: {
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
  };
}
