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
  base = [
    m.bigrig
    m.home-manager
    m.sree
    m.core
    m.secrets
    m.server-services
    m.server-packages
    m.shell
    m.hardware-tools
    m.ai-tools
    m.starship-bigrig
    m.nvf
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
