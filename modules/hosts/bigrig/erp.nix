# The ERP stack (github.com/lodgingzeus/erp), as rootless podman under its own
# user. Not on sree: sree is in wheel and runs every other container, so a
# separate user keeps the ERP podman secrets and Postgres data apart from them.
# Its quadlets come from the ERP repo (podman/install-quadlets.sh), not here.
#
# uid, gid, and the subuid range are pinned like the other users in host.nix,
# so restored volumes keep correct ownership.
{...}: {
  flake.modules.nixos.bigrig = {...}: {
    users.groups.erp.gid = 1002;
    users.users.erp = {
      isNormalUser = true;
      uid = 1002;
      group = "erp";
      # Start the ERP user units (podman quadlets) without a login session.
      linger = true;
      subUidRanges = [
        {
          startUid = 655360;
          count = 65536;
        }
      ];
      subGidRanges = [
        {
          startGid = 655360;
          count = 65536;
        }
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJj+EmkhR8opwF5DsQlGtjeZh5aM3BoX2GKszpbY9bfu sree2399@gmail.com"
      ];
    };

    # ERP_ROOT of install-quadlets.sh: the container logs live here.
    systemd.tmpfiles.rules = ["d /srv/erp 0750 erp erp -"];
  };
}
