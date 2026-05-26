{ pkgs, inputs, ... }:
{

  # install package
  environment.systemPackages = with pkgs; [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    # ... maybe other stuff
  ];


  home-manager.users.sree = {
    imports = [
      inputs.noctalia.homeModules.default
      ../home.nix
    ];

    programs.noctalia-shell = {
      enable = true;
      settings = (builtins.fromJSON(builtins.readFile ./noctalia.json)).settings;
      };
    };
}
