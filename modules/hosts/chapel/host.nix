{...}: {
  flake.modules.nixos.chapel = {
    config,
    pkgs,
    ...
  }: {
    networking.hostName = "chapel";
    time.timeZone = "Asia/Dubai";

    boot = {
      kernelModules = ["ntsync" "nct6687"];
      kernelPackages = pkgs.linuxKernel.packages.linux_zen;
      extraModulePackages = [config.boot.kernelPackages.nct6687d];

      loader = {
        efi.efiSysMountPoint = "/efi";
        systemd-boot.xbootldrMountPoint = "/boot";
      };

      initrd = {
        kernelModules = [
          "usb_storage"
          "uas"
          "ext4"
        ];
        luks.devices.luksroot = {
          device = "/dev/disk/by-uuid/85719e7e-dcea-4a0a-afe1-d0c796b0e59d";
          preLVM = true;
          allowDiscards = true;
          keyFile = "/lukskey.bin:/dev/disk/by-uuid/b233771c-80b9-4288-ad93-1716d277b5a7";
          crypttabExtraOpts = ["keyfile-timeout=5s"];
        };
      };
    };

    system.stateVersion = "25.11";
  };
}
