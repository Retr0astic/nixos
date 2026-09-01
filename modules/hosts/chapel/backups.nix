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
      # ~/.cache: regenerable. steamapps/common, /downloading, /shadercache:
      # installed game files, redownloadable from Steam. compatdata (Proton
      # prefixes) is deliberately NOT excluded — for games without Steam
      # Cloud support, that's the only copy of the save data, and it's
      # bundled in the same tree as the reproducible Proton install files.
      # Heroic's library isn't excluded either; its install path isn't
      # pinned anywhere in this repo, so add it here once you've checked
      # where it actually lands on chapel.
      exclude = [
        "/home/sree/.cache"
        "/home/sree/.local/share/Steam/steamapps/common"
        "/home/sree/.local/share/Steam/steamapps/downloading"
        "/home/sree/.local/share/Steam/steamapps/shadercache"
      ];
      repository = "/mnt/bigdrive/backups/chapel/home";
      passwordFile = resticPasswordFile;
      initialize = true;
      timerConfig = {
        OnCalendar = "daily";
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
