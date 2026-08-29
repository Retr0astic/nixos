# Pre-existing storage: two mdadm RAID0 arrays on the HDDs, an LVM VG for
# nextcloud/immich, and a plain btrfs backups disk. None of this is declared
# in disko — it survives the nvme0n1 reformat untouched.
#
# This machine was bricked once by a boot-blocking storage dependency.
# `nofail` is mandatory on every entry below.
{...}: {
  flake.modules.nixos.bigrig = {...}: {
    boot.swraid.enable = true;

    # One entry per btrfs device. `/` covers /home, /nix, /var and
    # /.snapshots, which are subvolumes of the same nvme0n1p2. /mnt/storage
    # and /mnt/Frigate are ext4 and cannot be scrubbed.
    services.btrfs.autoScrub.fileSystems = [
      "/"
      "/mnt/Vault"
      "/mnt/Nextcloud"
      "/mnt/Immich"
      "/mnt/backups"
    ];

    # The array homehost is `vega`, not bigrig — mdadm treats a foreign
    # homehost as a reason to skip auto-assembly, not just a naming quirk.
    # `HOMEHOST <ignore>` tells mdadm to assemble by UUID regardless of which
    # host created the array; the explicit ARRAY lines below are what it then
    # assembles. fileSystems below mount by filesystem UUID, so this doesn't
    # affect mounting once the arrays are up — only whether they come up at
    # all. Rename the arrays later (`mdadm --assemble --update=homehost`) if
    # stable /dev/md/vega:* paths under the new hostname are wanted instead.
    #
    # vega:0 is Vault, vega:1 is Storage. The vega:0 UUID here is regrouped
    # from the digits provided (mdadm.conf wants four 8-hex-digit groups);
    # verify against `mdadm --detail --scan` on the live system before relying
    # on it.
    boot.swraid.mdadmConf = ''
      HOMEHOST <ignore>
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

    # systemd defaults to a 90s mount timeout. Opening a 3.6T btrfs at 97%
    # full, striped across two spinning disks, does not reliably finish in
    # that window: the kernel logged `open_ctree failed: -4` (EINTR) after
    # systemd sent SIGTERM mid-mount. `nofail` already stops a slow mount
    # from blocking boot, so the timeout only needs to be generous.
    fileSystems."/mnt/Vault" = {
      device = "/dev/disk/by-uuid/332af57b-9183-49a1-9ab8-934bf9c3fef6";
      fsType = "btrfs";
      options = ["nofail" "compress=zstd" "noatime" "x-systemd.mount-timeout=15min"];
    };

    fileSystems."/mnt/backups" = {
      device = "/dev/disk/by-uuid/cefe7aff-8f29-4d74-897d-edbb316f2506";
      fsType = "btrfs";
      options = ["nofail" "compress=zstd" "noatime" "x-systemd.mount-timeout=15min"];
    };

    # Frigate recording clips live on /dev/sda1, the ext4 partition beside the
    # btrfs backups partition on the same disk.
    fileSystems."/mnt/Frigate" = {
      device = "/dev/disk/by-uuid/3b3db63d-fb3c-4277-9611-7f79bcec57b6";
      fsType = "ext4";
      options = ["nofail"];
    };

    # LVM VG nextcloud_immich on the 931.5G disk, LVs nextcloud_lv (200G) and
    # immich_lv (731.5G), both btrfs. LVM auto-activates the VG via its own
    # systemd/udev units; only the mountpoints need declaring here.
    fileSystems."/mnt/Nextcloud" = {
      device = "/dev/disk/by-uuid/b529ce87-7114-4416-8e24-085f60592548";
      fsType = "btrfs";
      options = ["nofail" "compress=zstd" "noatime" "x-systemd.mount-timeout=15min"];
    };

    fileSystems."/mnt/Immich" = {
      device = "/dev/disk/by-uuid/3e52436a-cfa1-4d21-9fd6-be5d34dac281";
      fsType = "btrfs";
      options = ["nofail" "compress=zstd" "noatime" "x-systemd.mount-timeout=15min"];
    };
  };
}
