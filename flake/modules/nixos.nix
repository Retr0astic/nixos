{...}: {
  flake.modules.nixos = {
    core = ../../modules/nixos/core;
    services = ../../modules/nixos/services;
    user = ../../modules/nixos/users/sree.nix;
    nvidia = ../../modules/nixos/hardware/nvidia.nix;
    gaming = ../../modules/nixos/programs/gaming.nix;
    zen = ../../modules/nixos/programs/zen.nix;
    lucidglyph = ../../modules/lucidglyph.nix;
  };
}
