{...}: {
  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShell {
      # gcc and python3 live here, not in systemPackages. Nothing on either
      # host needs a compiler at runtime.
      packages = with pkgs; [fish gcc python3];
      shellHook = ''
        export SHELL=${pkgs.fish}/bin/fish
        exec "$SHELL"
      '';
    };
  };
}
