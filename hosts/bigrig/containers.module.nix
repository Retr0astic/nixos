# Placeholder for rootless podman quadlet services. Real .container files are
# supplied separately; do not invent service definitions here.
#
# Volumes are restored from a backup of the old system. For restored file
# ownership to map correctly into sree's rootless user namespace, sree's
# UID/GID and subuid/subgid ranges must match the old system exactly.
# TODO: on the old system, record:
#   id sree
#   grep sree /etc/subuid /etc/subgid
# and set matching values here (e.g. `users.users.sree.uid = lib.mkForce ...;`,
# `users.users.sree.subUidRanges`/`subGidRanges`) before restoring volumes.
{...}: {
  # Quadlet units go to ~/.config/containers/systemd/*.container, where
  # podman's per-user systemd generator picks them up (sree has
  # `linger = true`, set in modules/features/server.nix, so this runs
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
}
