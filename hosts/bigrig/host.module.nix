{lib, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./disko.module.nix
    ./storage.module.nix
    ./containers.module.nix
  ];

  networking.hostName = "bigrig";
  time.timeZone = "Asia/Dubai";

  # TODO (do this before wiping the old system): copy its Samba config —
  # it defines the share-to-user mapping (sree/vicky/media/paperless) and
  # is not worth reconstructing from memory once gone.
  #   cp -a /mnt/root/etc/samba /mnt/backup/

  # TODO (do this before nixos-install, not after): `secrets` requires
  # sops.age.sshKeyPaths to decrypt passwd/sree, and that secret is
  # `neededForUsers = true`. On a headless box there is no greeter to fall
  # back to, so if bigrig boots once without a working key it cannot log in.
  # Generate the host key on the ISO first:
  #   ssh-keygen -t ed25519 -f /mnt/etc/ssh/ssh_host_ed25519_key -N ""
  #   ssh-to-age < /mnt/etc/ssh/ssh_host_ed25519_key.pub
  # add the result to .sops.yaml, run `sops updatekeys secrets/secrets.yaml`,
  # commit, and only then run nixos-install.

  # systemd-boot and efi.canTouchEfiVariables come from the shared `core`
  # module. No XBOOTLDR split and no LUKS here, unlike chapel: bigrig has one
  # plain ESP and no encrypted root.
  boot.loader.systemd-boot.configurationLimit = 10;

  system.stateVersion = "26.05";

  # Second way in, in case passwd/sree fails to decrypt (see the sops note
  # above).
  users.users.sree.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJj+EmkhR8opwF5DsQlGtjeZh5aM3BoX2GKszpbY9bfu sree2399@gmail.com"
  ];

  # Matches the old system exactly (`id sree`, `id vicky`, /etc/subuid,
  # /etc/subgid), so restored volumes keep correct ownership.
  users.groups.sree.gid = 1000;
  users.users.sree = {
    uid = lib.mkForce 1000;
    group = lib.mkForce "sree";
    subUidRanges = [
      {
        startUid = 524288;
        count = 65536;
      }
    ];
    subGidRanges = [
      {
        startGid = 524288;
        count = 65536;
      }
    ];
  };

  # vicky is a Samba-only account (no desktop/home-manager profile). The
  # Samba service itself isn't configured yet — add that when needed. This
  # only pins the uid/gid so restored files resolve to a name instead of a
  # raw number.
  users.groups.vicky.gid = 1001;
  users.users.vicky = {
    isNormalUser = true;
    uid = 1001;
    group = "vicky";
    subUidRanges = [
      {
        startUid = 589824;
        count = 65536;
      }
    ];
    subGidRanges = [
      {
        startGid = 589824;
        count = 65536;
      }
    ];
  };

  # media and paperless are not standalone accounts: their UIDs (525292,
  # 525287) fall inside sree's subuid range (524288-589823, offsets 1004 and
  # 999), so they are rootless container UIDs surfaced as host users purely
  # so Samba and `ls` can resolve a name instead of a raw number. No subuid
  # ranges of their own, no login: sree's linger + subuid range is what
  # actually runs their containers.
  users.groups.media.gid = 525292;
  users.users.media = {
    isNormalUser = true;
    uid = 525292;
    group = "media";
    home = "/home/media";
  };

  users.groups.paperless.gid = 525287;
  users.users.paperless = {
    isNormalUser = true;
    uid = 525287;
    group = "paperless";
    home = "/home/paperless";
  };
}
