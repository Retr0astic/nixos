{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/core
    ../../modules/nixos/hardware/nvidia.nix
    ../../modules/nixos/programs/gaming.nix
    ../../modules/nixos/programs/zen.nix
    ../../modules/nixos/services
    ../../modules/nixos/users/sree.nix
    ../../modules/lucidglyph.nix
    inputs.silentSDDM.nixosModules.default
  ];

  networking.hostName = "chapel";
  time.timeZone = "Asia/Dubai";

  boot.kernelModules = ["ntsync" "nct6687"];
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  boot.loader.efi.efiSysMountPoint = "/efi";
  boot.loader.systemd-boot.xbootldrMountPoint = "/boot";
  boot.initrd.kernelModules = [
    "usb_storage"
    "uas"
    "ext4"
  ];
  boot.initrd.luks.devices.luksroot = {
    device = "/dev/disk/by-uuid/85719e7e-dcea-4a0a-afe1-d0c796b0e59d";
    preLVM = true;
    allowDiscards = true;
    keyFile = "/lukskey.bin:/dev/disk/by-uuid/b233771c-80b9-4288-ad93-1716d277b5a7";
    crypttabExtraOpts = ["keyfile-timeout=5s"];
  };
  boot.extraModulePackages = [config.boot.kernelPackages.nct6687d];

  environment.etc."xdg/menus/applications.menu".source = ../../modules/dolphin.menu;
  environment.systemPackages = with pkgs; [
    qemu
    quickemu
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.nvf
  ];

  services.displayManager.defaultSession = "hyprland";
  system.stateVersion = "25.11";
}
