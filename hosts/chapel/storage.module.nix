{lib, ...}: {
  fileSystems."/mnt/bigdrive" = {
    device = lib.mkForce "/dev/disk/by-uuid/4f47f50d-1a45-457e-8d07-68183f1afd1e";
    fsType = lib.mkForce "btrfs";
    options = lib.mkForce ["rw" "nofail" "compress=zstd"];
  };

  fileSystems."/mnt/shared" = {
    device = "/dev/sda2";
    fsType = "exfat";
    options = ["rw" "nofail"];
  };
}
