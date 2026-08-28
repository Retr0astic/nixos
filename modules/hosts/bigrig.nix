{
  config,
  inputs,
  ...
}: let
  m = config.flake.modules.nixos;

  # Headless server: no graphics, gaming, browser, fonts, appearance,
  # media, file-managers, spicetify, opends5, audio, terminals, xdg, or any
  # compositor. Uses starship-bigrig instead of chapel's starship (different
  # style, no noctalia palette dependency).
  base = with m; [
    bigrig
    home-manager
    sree
    core
    secrets
    server-services
    server-packages
    shell
    hardware-tools
    ai-tools
    starship-bigrig
    nvf
  ];
in {
  flake.modules.nixos.bigrig = {
    imports = [
      ../../hosts/bigrig/host.module.nix
      inputs.disko.nixosModules.disko
    ];
  };

  flake.nixosConfigurations.bigrig = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = base;
  };
}
