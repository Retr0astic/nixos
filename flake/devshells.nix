{...}: {
  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShell {
      packages = [pkgs.fish];
      shellHook = ''
        export SHELL=${pkgs.fish}/bin/fish
        exec "$SHELL"
      '';
    };
  };
}
