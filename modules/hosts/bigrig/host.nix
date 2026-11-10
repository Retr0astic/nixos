{...}: {
  flake.modules.nixos.bigrig = {lib, ...}: {
    networking.hostName = "bigrig";
    time.timeZone = "Asia/Dubai";

    # systemd-boot and efi.canTouchEfiVariables come from the shared `core`
    # module. No XBOOTLDR split and no LUKS here, unlike chapel: bigrig has one
    # plain ESP and no encrypted root.
    boot.loader.systemd-boot.configurationLimit = 10;

    system.stateVersion = "26.05";

    # The only way in over SSH: `server-services` turns password login off.
    # It is also the way in when passwd/sree fails to decrypt. That secret
    # is `neededForUsers`, and a headless host has no greeter to fall back
    # to.
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
  };
}
