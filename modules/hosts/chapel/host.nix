{...}: {
  flake.modules.nixos.chapel = {
    config,
    pkgs,
    ...
  }: {
    networking.hostName = "chapel";
    time.timeZone = "Asia/Dubai";

    # chapel is a desktop and is off at 05:30, which is what the shared
    # auto-upgrade aspect assumes. The restic timer in backups.nix answers
    # the same problem with 14:00, so this sits two hours after it and does
    # not compete with the backup for the disk. A day when the machine is
    # off at 16:00 too is not lost: the timer is persistent, so the run
    # happens at the next boot, after the 45 minute delay.
    system.autoUpgrade.dates = "16:00";

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
