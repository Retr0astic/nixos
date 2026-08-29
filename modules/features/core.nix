{...}: {
  # Shared by every host, desktop or headless.
  flake.modules.nixos.core = {pkgs, ...}: {
    # Set here, not as `nixosSystem { system = ...; }`, so a future aarch64
    # host is one line in its own aspect rather than an argument in every
    # host file.
    nixpkgs.hostPlatform = "x86_64-linux";

    # Needed before any user session exists: recovery shell, root over SSH,
    # and `nixos-rebuild` on a machine whose home-manager generation failed.
    environment.systemPackages = with pkgs; [
      vim
      git
      wget
      # TODO: verify. Carried over from the old system-packages list with no
      # recorded reason. Drop it if nothing regresses.
      bubblewrap
    ];

    services.fstrim.enable = true;

    # /tmp is a directory on the root disk, not a tmpfs. Without this it is
    # only pruned by systemd-tmpfiles after ten untouched days, which let it
    # reach 2.5G on chapel. Not useTmpfs: that would put /tmp in RAM, and
    # bigrig has none to spare.
    boot.tmp.cleanOnBoot = true;

    # Both hosts run btrfs on root. A scrub reads every block and verifies
    # it against its checksum, which is the only way to find silent
    # corruption before you need the data. bigrig had never run one.
    # The per-host `fileSystems` list sits with the mounts it covers, in
    # each host's storage aspect: one entry per device, not per subvolume,
    # or the same disk gets scrubbed several times.
    services.btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
    };

    # Nothing collected old generations, so both hosts kept every build
    # ever made. `--delete-older-than` counts from the generation date, so
    # the current one is never a candidate.
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # Hard-links identical files across store paths. Separate from gc:
    # collection removes whole paths, this deduplicates what remains.
    nix.optimise = {
      automatic = true;
      dates = ["weekly"];
    };

    # Journals were unbounded and had reached 1.5G on chapel.
    services.journald.extraConfig = ''
      SystemMaxUse=500M
      SystemMaxFileSize=50M
    '';

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    networking.networkmanager.enable = true;
    nix.settings.experimental-features = ["nix-command" "flakes"];
    nix.settings.trusted-users = ["root"];
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.permittedInsecurePackages = ["pnpm-10.29.2" "electron-39.8.10" "electron-40.10.5"];
    programs.nix-ld = {
      enable = true;
      libraries = [];
    };
  };
}
