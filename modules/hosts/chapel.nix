{
  config,
  inputs,
  ...
}: let
  m = config.flake.modules.nixos;

  # Every configuration of this machine starts from these modules.
  base = with m; [
    chapel
    home-manager
    sree
    core
    secrets
    services
    graphics
    gaming
    zen
    fonts
    appearance
    system-packages
    programs
    shell
    terminals
    xdg
    starship
    audio
    nvf
    spicetify
    opends5
    overlays
  ];

  # Add a desktop and a shell to build one variant.
  mk = extra:
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = base ++ extra;
    };

  # Write `m.<name>` here. A bare name would pick up the attribute below it.
  withNoctalia = mk [m.hyprland m.noctalia];
  withCaelestia = mk [m.hyprland m.caelestia];
in {
  flake.modules.nixos.chapel = {
    imports = [
      ../../hosts/chapel/host.module.nix
      inputs.noctalia-greeter.nixosModules.default
    ];

    home-manager.sharedModules = [config.flake.modules.homeManager.chapel];
  };

  flake.nixosConfigurations = {
    noctalia-hyprland = withNoctalia;
    caelestia-hyprland = withCaelestia;

    # Short names for the same two builds.
    chapel = withNoctalia;
    chapel-hyprland-noctalia = withNoctalia;
    noctalia = withNoctalia;
    caelestia = withCaelestia;
  };
}
