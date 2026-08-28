# TODO: this is a placeholder, not a generated hardware-configuration.nix.
# After disko has formatted nvme0n1 on the live ISO, run:
#   nixos-generate-config --no-filesystems --root /mnt
# then copy `boot.initrd.availableKernelModules`, `boot.initrd.kernelModules`,
# `boot.kernelModules`, `boot.extraModulePackages` and the
# `hardware.cpu.*.updateMicrocode` line from the generated file into this one.
# Skip its `fileSystems` and `swapDevices` entries: disko.module.nix and
# storage.module.nix already own those.
{
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = []; # TODO: fill in from nixos-generate-config
  boot.initrd.kernelModules = []; # TODO: fill in from nixos-generate-config
  boot.kernelModules = []; # TODO: fill in from nixos-generate-config
  boot.extraModulePackages = [];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
