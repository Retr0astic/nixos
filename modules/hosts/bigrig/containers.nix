# Placeholder for rootless podman quadlet services. Real .container files are
# supplied separately; do not invent service definitions here.
#
# Volumes are restored from a backup of the old system. sree's uid/gid and
# subuid/subgid ranges are pinned in host.nix to match the old system
# exactly, so restored file ownership maps correctly into sree's rootless
# user namespace.
{...}: {
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
  };
}
