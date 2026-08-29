# Declares nvme0n1 only. `--mode disko` wipes and rebuilds every partition
# declared here for this disk — it does not preserve the existing ESP. Do not
# add the HDDs, the LVM disk, or the mdadm arrays here: they are pre-existing
# and disko must never touch them.
{...}: {
  flake.modules.nixos.bigrig = {...}: {
    disko.devices.disk.nvme0n1 = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-SN530_SDBPNPZ-512G-1004_212429803514";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G"; # old ESP was 572M; 1G gives headroom for generations
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["umask=0077"];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = ["-f"];
              subvolumes = {
                "@" = {
                  mountpoint = "/";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "@home" = {
                  mountpoint = "/home";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "@var" = {
                  mountpoint = "/var";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                # Not in the spec: /.snapshots is the conventional snapper
                # mountpoint. Say if you want it elsewhere.
                "@snapshots" = {
                  mountpoint = "/.snapshots";
                  mountOptions = ["compress=zstd" "noatime"];
                };
              };
            };
          };
        };
      };
    };
  };
}
