{lib, ...}: {
  fileSystems."/mnt/bigdrive" = {
    device = lib.mkForce "/dev/sda1";
    fsType = lib.mkForce "btrfs";
    options = lib.mkForce ["rw" "nofail" "compress=zstd"];
  };

  fileSystems."/mnt/shared" = {
    device = "/dev/sda2";
    fsType = "exfat";
    options = ["rw" "nofail"];
  };
}
