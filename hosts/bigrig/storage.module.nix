# Pre-existing storage: two mdadm RAID0 arrays on the HDDs, an LVM VG for
# nextcloud/immich, and a plain btrfs backups disk. None of this is declared
# in disko — it survives the nvme0n1 reformat untouched.
#
# This machine was bricked once by a boot-blocking storage dependency.
# `nofail` is mandatory on every entry below.
{...}: {
  boot.swraid.enable = true;

  # The array homehost is `vega`, not bigrig — that's why md126/md127 assign
  # semi-randomly instead of stable /dev/md/<name> paths. Assembly below is
  # by UUID, so this doesn't affect boot; fileSystems reference the arrays by
  # label too. Set HOMEHOST or rename the arrays later if stable /dev/md/
  # paths are wanted.
  #
  # vega:0 is Vault, vega:1 is Storage. The vega:0 UUID here is regrouped
  # from the digits provided (mdadm.conf wants four 8-hex-digit groups);
  # verify against `mdadm --detail --scan` on the live system before relying
  # on it.
  boot.swraid.mdadmConf = ''
    MAILADDR root
    ARRAY /dev/md/vega:1 metadata=1.2 UUID=cedfacc0:73d5c703:1b46f284:87d141be name=vega:1
    ARRAY /dev/md/vega:0 metadata=1.2 UUID=a224fd89:a8aab8c3:a0034335:3b3f3203 name=vega:0
  '';

  # Mountpoints are not in the spec, chosen to match the array labels. Say if
  # you want them elsewhere.
  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-uuid/73f1114d-dc49-40f8-be05-fa25af015ec9";
    fsType = "ext4";
    options = ["nofail"];
  };

  fileSystems."/mnt/vault" = {
    device = "/dev/disk/by-uuid/332af57b-9183-49a1-9ab8-934bf9c3fef6";
    fsType = "btrfs";
    options = ["nofail" "compress=zstd" "noatime"];
  };

  fileSystems."/mnt/backups" = {
    device = "/dev/disk/by-uuid/cefe7aff-8f29-4d74-897d-edbb316f2506";
    fsType = "btrfs";
    options = ["nofail" "compress=zstd" "noatime"];
  };

  # LVM VG nextcloud_immich on the 931.5G disk, LVs nextcloud_lv (200G) and
  # immich_lv (731.5G), both btrfs. LVM auto-activates the VG via its own
  # systemd/udev units; only the mountpoints need declaring here.
  fileSystems."/mnt/nextcloud" = {
    device = "/dev/disk/by-uuid/b529ce87-7114-4416-8e24-085f60592548";
    fsType = "btrfs";
    options = ["nofail" "compress=zstd" "noatime"];
  };

  fileSystems."/mnt/immich" = {
    device = "/dev/disk/by-uuid/3e52436a-cfa1-4d21-9fd6-be5d34dac281";
    fsType = "btrfs";
    options = ["nofail" "compress=zstd" "noatime"];
  };
}
