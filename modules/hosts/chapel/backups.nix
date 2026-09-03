# Daily restic backup of sree's home, onto the big local drive (see
# storage.nix — /mnt/bigdrive, btrfs, UUID 4f47f50d-1a45-457e-8d07-68183f1afd1e).
# Repo gets its own folder there so it doesn't fight anything else that
# lands on /mnt/bigdrive later.
#
# Reuses bigrig's restic_password secret (same repo password across both
# hosts' backups) — see modules/hosts/bigrig/backups.nix. Both hosts already
# hold an age key for secrets/secrets.yaml (.sops.yaml), so this just needs
# its own sops.secrets declaration to materialize the same ciphertext here.
{...}: {
  flake.modules.nixos.chapel = {config, ...}: let
    resticPasswordFile = config.sops.secrets.restic_password.path;
  in {
    sops.secrets.restic_password = {};

    services.restic.backups.home = {
      paths = ["/home/sree"];
      # ~/.cache: regenerable. Both Steam libraries' steamapps/common,
      # /downloading, /shadercache, /workshop, /temp: installed game files,
      # redownloadable from Steam. compatdata (Proton prefixes) is
      # deliberately NOT excluded, in either library — for games without
      # Steam Cloud support, that's the only copy of the save data, and
      # it's bundled in the same tree as the reproducible Proton install
      # files. This is a glob so a third Steam library, if one ever shows
      # up, doesn't need adding by hand.
      #
      # ~/Games/Heroic and ~/Games/Manual (hand-installed games, e.g. copies
      # that aren't through Steam/Heroic) are excluded wholesale — both are
      # stable launcher/convention names, not per-game paths, so new or
      # removed games never need an edit here. Heroic mixes save data into
      # its Wine prefixes unpredictably (one prefix held a 133G game
      # install), and manual installs have no consistent save location
      # either, so there's no clean install-vs-save split to preserve there
      # like Steam's compatdata gives us — Heroic/manual-install saves are
      # NOT backed up.
      #
      # ~/Projects/virtualmachines: VM disk images, reproducible from
      # ISOs/setup. ~/.local/share/containers: podman/docker storage,
      # regenerable. */target: Cargo build output, regenerable via
      # `cargo build` — this is a glob so future Rust projects under
      # ~/Projects don't need adding one at a time.
      exclude = [
        "/home/sree/.cache"
        "/home/sree/*/Steam/steamapps/common"
        "/home/sree/*/Steam/steamapps/downloading"
        "/home/sree/*/Steam/steamapps/shadercache"
        "/home/sree/*/Steam/steamapps/workshop"
        "/home/sree/*/Steam/steamapps/temp"
        "/home/sree/.local/share/Steam/steamapps/common"
        "/home/sree/.local/share/Steam/steamapps/downloading"
        "/home/sree/.local/share/Steam/steamapps/shadercache"
        "/home/sree/.local/share/Steam/steamapps/workshop"
        "/home/sree/.local/share/Steam/steamapps/temp"
        "/home/sree/Games/Heroic"
        "/home/sree/Games/Manual"
        "/home/sree/Projects/virtualmachines"
        "/home/sree/.local/share/containers"
        "/home/sree/Projects/*/target"
      ];
      repository = "/mnt/bigdrive/backups/chapel/home";
      passwordFile = resticPasswordFile;
      initialize = true;
      timerConfig = {
        OnCalendar = "14:00";
        Persistent = true;
      };
      pruneOpts = [
        "--keep-last 3"
        "--keep-daily 14"
        "--keep-weekly 8"
        "--keep-monthly 12"
        "--keep-within 14d"
      ];
    };
  };
}
