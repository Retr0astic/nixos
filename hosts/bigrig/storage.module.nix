# Pre-existing storage: two mdadm RAID0 arrays on the HDDs, an LVM VG for
# nextcloud/immich, and a plain btrfs backups disk. None of this is declared
# in disko — it survives the nvme0n1 reformat untouched.
#
# This machine was bricked once by a boot-blocking storage dependency.
# `nofail` is mandatory on every entry below.
{...}: {
  boot.swraid.enable = true;

  # TODO: paste the ARRAY lines from `mdadm --detail --scan` here, e.g.:
  #   ARRAY /dev/md/Storage metadata=1.2 UUID=xxxxxxxx:xxxxxxxx:xxxxxxxx:xxxxxxxx name=bigrig:Storage
  #   ARRAY /dev/md/Vault   metadata=1.2 UUID=xxxxxxxx:xxxxxxxx:xxxxxxxx:xxxxxxxx name=bigrig:Vault
  # This is what lets mdadm assemble the arrays consistently even though the
  # md126/md127 device numbers swap between boots.
  boot.swraid.mdadmConf = ''
    MAILADDR root
    # TODO: ARRAY lines from `mdadm --detail --scan`
  '';

  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-label/Storage";
    fsType = "ext4";
    options = ["nofail"];
  };

  fileSystems."/mnt/vault" = {
    device = "/dev/disk/by-label/Vault";
    fsType = "btrfs";
    options = ["nofail" "compress=zstd" "noatime"];
  };

  fileSystems."/mnt/backups" = {
    device = "/dev/disk/by-label/Backups";
    fsType = "btrfs";
    options = ["nofail" "compress=zstd" "noatime"];
  };

  # LVM VG nextcloud_immich on the 931.5G disk, LVs nextcloud_lv (200G) and
  # immich_lv (731.5G), both btrfs. LVM auto-activates the VG via its own
  # systemd/udev units; only the mountpoints need declaring here.
  fileSystems."/mnt/nextcloud" = {
    # TODO: replace with the real UUID. Get it on the live ISO with:
    #   blkid /dev/nextcloud_immich/nextcloud_lv
    device = "/dev/disk/by-uuid/TODO-nextcloud-lv-uuid";
    fsType = "btrfs";
    options = ["nofail" "compress=zstd" "noatime"];
  };

  fileSystems."/mnt/immich" = {
    # TODO: replace with the real UUID. Get it on the live ISO with:
    #   blkid /dev/nextcloud_immich/immich_lv
    device = "/dev/disk/by-uuid/TODO-immich-lv-uuid";
    fsType = "btrfs";
    options = ["nofail" "compress=zstd" "noatime"];
  };
}
