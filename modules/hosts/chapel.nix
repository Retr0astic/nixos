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
    m.auto-upgrade
    m.memory
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

  # What the update timer follows, named per variant. `m.auto-upgrade`
  # derives that reference from the host name, and every variant here has
  # the host name `chapel`, so a machine on `chapel-umbriel` would wake up
  # staged back to the plain chapel build. The variant knows its own name,
  # so it states it.
  upgradeTarget = name: {
    system.autoUpgrade.flake = "github:Retr0astic/nixos/main#${name}";
  };

  # Add a desktop and a shell to build one variant. The name is the flake
  # output name below.
  mk = name: extra:
    inputs.nixpkgs.lib.nixosSystem {
      modules = base ++ extra ++ [(upgradeTarget name)];
    };

  # Write `m.<name>` here. A bare name would pick up the attribute below it.
  withNoctalia = mk "chapel" [m.hyprland m.noctalia];
  withCaelestia = mk "chapel-caelestia" [m.hyprland m.caelestia];
  withNoctaliaUmbriel = mk "chapel-umbriel" [m.umbriel m.noctalia];
  # The noctalia build plus a second greeter entry, "Hyprland (end-4)".
  withEnd4 = mk "chapel-end4" [m.hyprland m.noctalia m.end4];
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
    chapel-umbriel = withNoctaliaUmbriel;
    chapel-end4 = withEnd4;
  };
}
