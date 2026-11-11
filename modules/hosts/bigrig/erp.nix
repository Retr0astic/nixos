# The ERP stack (github.com/lodgingzeus/erp), as rootless podman under its own
# user. Not on sree: sree is in wheel and runs every other container, so a
# separate user keeps the ERP podman secrets and Postgres data apart from them.
# Its quadlets come from the ERP repo (podman/install-quadlets.sh), not here.
#
# uid, gid, and the subuid range are pinned like the other users in host.nix,
# so restored volumes keep correct ownership. 1003, not 1002: gid 1002 is
# vaultshare (samba.nix), the group that owns /mnt/Vault/share. NixOS does
# not move an existing user, so the 1002 -> 1003 move ran by hand with
# usermod/groupmod on 2026-11-11.
{...}: {
  flake.modules.nixos.bigrig = {config, ...}: {
    users.groups.erp.gid = 1003;
    users.users.erp = {
      isNormalUser = true;
      uid = 1003;
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
      # The same keys as sree, written once in host.nix.
      openssh.authorizedKeys.keys = config.users.users.sree.openssh.authorizedKeys.keys;
    };

    # ERP_ROOT of install-quadlets.sh: the container logs live here.
    systemd.tmpfiles.rules = ["d /srv/erp 0750 erp erp -"];
  };
}
