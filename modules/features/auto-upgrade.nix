{...}: {
  # Pull-based delivery of an update that already passed review.
  #
  # The chain is: .github/workflows/flake-update.yml opens one pull request
  # per flake input, flake.yml builds that pull request, you merge it into
  # `testing`, and you fast-forward `main` when you trust the result. This
  # aspect is the last link. It fetches `main` once a day and stages what it
  # finds. It never decides what to install and it never picks a revision.
  #
  # Not on chapel. A desktop that carries the checkout rebuilds by hand from
  # ~/nixos, and a timer that stages `main` behind that would hand the next
  # reboot an older generation than the one you just switched to. Add
  # `m.auto-upgrade` to the chapel base list only after that checkout stops
  # being the source of truth for the machine.
  flake.modules.nixos.auto-upgrade = {
    config,
    lib,
    ...
  }: {
    system.autoUpgrade = {
      enable = true;

      # Derived from the host name, so a new host needs no edit here. A
      # machine that runs a variant is the exception: `chapel-umbriel` has
      # host name `chapel`, so the timer would quietly move it back to the
      # plain chapel build. Such a host sets this line itself.
      flake = lib.mkDefault "github:Retr0astic/nixos/main#${config.networking.hostName}";

      # `boot` writes the generation and the boot entry, then stops. Every
      # running service, the kernel and the drivers stay as they are until
      # the next reboot, which is the whole point on a machine that serves
      # 84 containers. `switch` would restart every changed unit instead.
      #
      # The cost is that an update is only live after a reboot. Check what
      # is staged with `nixos-rebuild list-generations`, or read the boot
      # menu default.
      operation = lib.mkDefault "boot";

      # The module supplies `--refresh --flake <uri>` on its own. This list
      # merges with that one rather than replacing it, so name only the
      # extra flags.
      #
      # --accept-flake-config: the substituters in flake.nix `nixConfig` are
      # a question for an interactive user and a silent no for a systemd
      # unit. Without this flag root ignores chapel.cachix.org and rebuilds
      # nvidia, hyprland and noctalia from source, on the server, at 05:30.
      flags = ["--accept-flake-config"];

      # `--upgrade` updates nix channels. This repository has none, and the
      # flake reference above carries its own lock. The module appends the
      # flag unless this option is false.
      upgrade = false;

      # Local time, not UTC. The workflow cron is unrelated: hosts follow
      # `main`, and `main` only moves when you merge.
      dates = "05:30";

      # The timer is persistent, so a machine that was off at 05:30 runs the
      # job at the next boot. The delay keeps that build off the first
      # minutes of a boot, when podman is still starting containers.
      randomizedDelaySec = "45min";
      persistent = true;

      # nix.gc in `core` already runs weekly. A second collection here would
      # race that one and delete the closure this job just fetched.
      runGarbageCollection = false;
    };

    # The unit reports only to the journal. A failed build leaves the
    # running system untouched, so a silent failure costs an update, never
    # the machine:
    #   systemctl is-failed nixos-upgrade.service
    #   journalctl -u nixos-upgrade.service -n 50
  };
}
