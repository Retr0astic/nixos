{inputs, ...}: {
  flake.modules.nixos.chapel = {
    imports = [
      ../../../modules/nixos/core
      ../../../modules/nixos/services
      ../../../modules/nixos/users/sree.nix
      ../../../modules/nixos/hardware/nvidia.nix
      ../../../modules/nixos/programs/gaming.nix
      ../../../modules/nixos/programs/zen.nix
      ../../../modules/lucidglyph.nix
      inputs.silentSDDM.nixosModules.default
    ];
  };
}
