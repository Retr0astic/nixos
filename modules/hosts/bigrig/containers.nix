# Placeholder for rootless podman quadlet services. Real .container files are
# supplied separately; do not invent service definitions here.
#
# Volumes are restored from a backup of the old system. sree's uid/gid and
# subuid/subgid ranges are pinned in host.nix to match the old system
# exactly, so restored file ownership maps correctly into sree's rootless
# user namespace.
{config, ...}: {
  flake.modules.nixos.bigrig = {...}: {
    # Quadlet units go to ~/.config/containers/systemd/*.container, where
    # podman's per-user systemd generator picks them up (sree has
    # `linger = true`, set in modules/features/server-services.nix, so this runs
    # without a login session).
    #
    # Example (uncomment and adjust once real .container files are supplied):
    # home-manager.users.sree.xdg.configFile."containers/systemd/example.container".text = ''
    #   [Container]
    #   Image=docker.io/library/nginx:latest
    #   PublishPort=8080:80
    #
    #   [Install]
    #   WantedBy=default.target
    # '';

    # container-notify-failure@ needs the webhook credential readable by
    # sree (backups.nix's copy is root-only, for the root-run restic/btrbk
    # services). Same ciphertext, a second decrypted copy owned by sree —
    # `key` points both nix attrs at the same yaml entry in secrets.yaml.
    sops.secrets.restic_notify_credentials_sree = {
      key = "restic_notify_credentials";
      owner = "sree";
    };

    home-manager.sharedModules = [config.flake.modules.homeManager.container-notify];
  };

  # User-scope counterpart to restic-notify-failure@ in backups.nix, for
  # quadlet .container units to point their [Unit] OnFailure= at (they run
  # under sree's user systemd instance, not the system one, so they can't
  # target the system-level template directly). Add
  # `OnFailure=container-notify-failure@%n.service` to a .container file's
  # [Unit] section to wire it up.
  flake.modules.homeManager.container-notify = {pkgs, ...}: let
    notifyScript = pkgs.writeShellApplication {
      name = "container-notify-failure";
      runtimeInputs = [pkgs.curl pkgs.systemd pkgs.coreutils];
      text = ''
        unit="$1"

        result=$(systemctl --user show "$unit" -p Result --value)
        exit_code=$(systemctl --user show "$unit" -p ExecMainStatus --value)
        reason=$(journalctl --user -u "$unit" -p err -n 3 --no-pager -o cat)
        [ -z "$reason" ] && reason="(no error line found, see: journalctl --user -u $unit)"

        {
          echo "❌ $unit failed"
          echo "Reason: $reason"
          echo "Result: $result | Exit: $exit_code"
          echo "Host: $(uname -n) | $(date '+%Y-%m-%d %H:%M %Z')"
        } | curl --config /run/secrets/restic_notify_credentials_sree --data-binary @- https://notify.retr0astic.com/backups
      '';
    };
  in {
    systemd.user.services."container-notify-failure@" = {
      Unit.Description = "Notify notify.retr0astic.com of a failed container";
      Service = {
        Type = "oneshot";
        ExecStart = "${notifyScript}/bin/container-notify-failure %i";
      };
    };
  };
}
