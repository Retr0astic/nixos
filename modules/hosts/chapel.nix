{
  config,
  inputs,
  ...
}: let
  m = config.flake.modules.nixos;

  # Every configuration of this machine starts from these modules. Every
  # entry carries `m.`: under `with m;` a bare name loses to a `let`
  # binding of the same name, and picks up the wrong value with no error.
  base = [
    m.chapel
    m.home-manager
    m.sree
    m.core
    m.core-desktop
    m.secrets
    m.services
    m.graphics
    m.gaming
    m.zen
    m.fonts
    m.appearance
    m.desktop-packages
    m.media
    m.file-managers
    m.hardware-tools
    m.ai-tools
    m.programs
    m.shell
    m.terminals
    m.xdg
    m.starship
    m.audio
    m.nvf
    m.spicetify
    m.opends5
  ];

  # Add a desktop and a shell to build one variant.
  mk = extra:
    inputs.nixpkgs.lib.nixosSystem {
      modules = base ++ extra;
    };

  # Write `m.<name>` here. A bare name would pick up the attribute below it.
  withNoctalia = mk [m.hyprland m.noctalia];
  withCaelestia = mk [m.hyprland m.caelestia];
in {
  flake.modules.nixos.chapel = {
    imports = [
      ../../hosts/chapel/hardware-configuration.nix
      inputs.noctalia-greeter.nixosModules.default
    ];

    home-manager.sharedModules = [config.flake.modules.homeManager.chapel];
  };

  # One name per build. `chapel` matches the hostname, so a bare
  # `nixos-rebuild --flake ~/nixos` picks it.
  flake.nixosConfigurations = {
    chapel = withNoctalia;
    chapel-caelestia = withCaelestia;
  };
}
