{...}: {
  # Compressed swap and the reclaim tunables that go with it. Shared by
  # every host: chapel and bigrig want the same values here, so they live
  # in one place rather than twice.
  #
  # Host-specific memory settings do not belong here. bigrig's writeback
  # limits sit in server-services.nix.
  flake.modules.nixos.memory = {...}: {
    # memoryPercent is the uncompressed capacity, not the memory cost. zstd
    # reaches about 3:1 on real workloads, so a device sized at 100% of RAM
    # costs roughly a third of RAM when completely full. The module default
    # of 50 is an lzo-era figure.
    #
    # Fedora ships the same shape (1.0 of RAM, capped at 8 GiB). Going past
    # 100% is not safe on a host that stays over-committed: a device at 3x
    # RAM, once full, holds its compressed pages in all of RAM.
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 100;
    };

    boot.kernel.sysctl = {
      # Swapping to zram costs a memcpy and a decompress, not a disk seek,
      # so the kernel should reach for it before it drops page cache. The
      # default of 60 assumes a spinning disk.
      "vm.swappiness" = 150;

      # Swap readahead. The default of 3 reads 8 pages per fault, which
      # pays off on a disk with seek latency to amortise. zram has none,
      # so the extra 7 pages are wasted work. This is the standard
      # companion to zram and the kernel does not set it for you.
      "vm.page-cluster" = 0;

      # Start kswapd reclaiming earlier. At the default of 10 the kernel
      # waits until it is nearly out, then stalls allocating threads in
      # direct reclaim. bigrig showed this as kswapd0 burning a quarter of
      # a core with five OOM kills in the first half hour.
      "vm.watermark_scale_factor" = 125;

      # Keep dentry and inode cache longer. Both hosts walk large trees:
      # bigrig across 84 containers, chapel across the nix store.
      "vm.vfs_cache_pressure" = 50;
    };
  };
}
